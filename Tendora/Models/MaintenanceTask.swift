//
//  MaintenanceTask.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import Foundation
import SwiftData

@Model
final class MaintenanceTask {
    var id: UUID = UUID()
    var title: String = ""
    var createdAt: Date = Date.now
    var dueDate: Date = Date.now
    var notes: String?
    var isCompleted: Bool = false
    var repeatRule: RepeatRule = RepeatRule.never
    var customRepeatValue: Int?
    var customRepeatUnit: RepeatUnit?
    var reminderEnabled: Bool = false
    var reminderOffset: ReminderOffset = ReminderOffset.oneWeekBefore
    var asset: Asset?
    @Relationship(deleteRule: .cascade, inverse: \CompletionRecord.task)
    var completionRecords: [CompletionRecord]? = []
    @Relationship(deleteRule: .cascade, inverse: \Attachment.task)
    var attachments: [Attachment]? = []

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = .now,
        dueDate: Date,
        notes: String? = nil,
        isCompleted: Bool = false,
        repeatRule: RepeatRule = .never,
        customRepeatValue: Int? = nil,
        customRepeatUnit: RepeatUnit? = nil,
        reminderEnabled: Bool = false,
        reminderOffset: ReminderOffset = .oneWeekBefore,
        asset: Asset? = nil,
        completionRecords: [CompletionRecord] = [],
        attachments: [Attachment] = []
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.notes = notes
        self.isCompleted = isCompleted
        self.repeatRule = repeatRule
        self.customRepeatValue = customRepeatValue
        self.customRepeatUnit = customRepeatUnit
        self.reminderEnabled = reminderEnabled
        self.reminderOffset = reminderOffset
        self.asset = asset
        self.completionRecords = completionRecords
        self.attachments = attachments
    }

    var nextDueDateAfterCompletion: Date? {
        repeatRule.nextDate(after: dueDate, customValue: customRepeatValue, customUnit: customRepeatUnit)
    }

    func markCompleted(on date: Date = .now) {
        completionRecords = (completionRecords ?? []) + [CompletionRecord(completedAt: date, task: self)]

        if let nextDueDateAfterCompletion {
            dueDate = nextDueDateAfterCompletion
            isCompleted = false
        } else {
            isCompleted = true
        }
    }

    var repeatSummary: String {
        repeatSummary(locale: .current)
    }

    func repeatSummary(locale: Locale) -> String {
        switch repeatRule {
        case .custom:
            guard let customRepeatValue, let customRepeatUnit else {
                return repeatRule.displayName(locale: locale)
            }

            let format = String(localized: "task.repeat.custom_format", locale: locale)
            return String(format: format, locale: locale, customRepeatValue, customRepeatUnit.displayName(locale: locale))
        default:
            return repeatRule.displayName(locale: locale)
        }
    }

    var currentStatus: String {
        currentStatus(locale: .current)
    }

    func currentStatus(locale: Locale) -> String {
        if isCompleted {
            return String(localized: "task.status.completed", locale: locale)
        }

        if dueDate < .now {
            return String(localized: "task.status.overdue", locale: locale)
        }

        if Calendar.current.dateComponents([.day], from: .now, to: dueDate).day ?? 0 <= 7 {
            return String(localized: "task.status.due_soon", locale: locale)
        }

        return String(localized: "task.status.normal", locale: locale)
    }

    var reminderSummary: String {
        reminderSummary(locale: .current)
    }

    func reminderSummary(locale: Locale) -> String {
        guard reminderEnabled else {
            return String(localized: "task.reminder.off", locale: locale)
        }

        return reminderOffset.displayName(locale: locale)
    }
}
