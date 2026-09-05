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
        switch repeatRule {
        case .custom:
            guard let customRepeatValue, let customRepeatUnit else {
                return repeatRule.displayName
            }

            let format = String(localized: "task.repeat.custom_format")
            return String(format: format, locale: .current, customRepeatValue, customRepeatUnit.displayName)
        default:
            return repeatRule.displayName
        }
    }

    var currentStatus: String {
        if isCompleted {
            return String(localized: "task.status.completed")
        }

        if dueDate < .now {
            return String(localized: "task.status.overdue")
        }

        if Calendar.current.dateComponents([.day], from: .now, to: dueDate).day ?? 0 <= 7 {
            return String(localized: "task.status.due_soon")
        }

        return String(localized: "task.status.normal")
    }

    var reminderSummary: String {
        guard reminderEnabled else {
            return String(localized: "task.reminder.off")
        }

        return reminderOffset.displayName
    }
}
