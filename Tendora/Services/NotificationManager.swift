//
//  NotificationManager.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import Foundation
import UserNotifications

enum NotificationManagerError: LocalizedError {
    case authorizationDenied
    case requestFailed
    case schedulingFailed

    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return String(localized: "error.notifications.denied.message")
        case .requestFailed:
            return String(localized: "error.notifications.request_failed.message")
        case .schedulingFailed:
            return String(localized: "error.notifications.scheduling_failed.message")
        }
    }
}

@MainActor
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        center.delegate = self
    }

    func configure() {
        center.delegate = self
    }

    func requestAuthorizationIfNeeded() async throws -> Bool {
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                throw NotificationManagerError.requestFailed
            }
        @unknown default:
            return false
        }
    }

    func scheduleNotification(for task: MaintenanceTask) async throws {
        await cancelNotification(for: task)

        guard task.reminderEnabled,
              task.isCompleted == false,
              let triggerDate = adjustedTriggerDate(for: task),
              triggerDate > .now
        else {
            return
        }

        let isAuthorized = try await requestAuthorizationIfNeeded()
        guard isAuthorized else {
            throw NotificationManagerError.authorizationDenied
        }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.title")
        content.body = notificationBody(for: task)
        content.sound = .default

        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: task),
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            throw NotificationManagerError.schedulingFailed
        }
    }

    func cancelNotification(for task: MaintenanceTask) async {
        let identifier = notificationIdentifier(for: task)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    private func notificationIdentifier(for task: MaintenanceTask) -> String {
        "tendora.task.\(task.id.uuidString)"
    }

    private func notificationBody(for task: MaintenanceTask) -> String {
        let assetName = task.asset?.name ?? String(localized: "app.name")
        let format = String(localized: "notification.body.format")
        let dueDate = task.dueDate.formatted(date: .abbreviated, time: .omitted)
        return String(format: format, locale: .current, task.title, assetName, dueDate)
    }

    private func adjustedTriggerDate(for task: MaintenanceTask, now: Date = .now) -> Date? {
        guard let triggerDate = task.reminderOffset.triggerDate(for: task.dueDate) else {
            return nil
        }

        if triggerDate > now {
            return triggerDate
        }

        if task.reminderOffset == .sameDay, Calendar.current.isDate(task.dueDate, inSameDayAs: now) {
            return now.addingTimeInterval(60)
        }

        return triggerDate
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
