//
//  TendoraSchemaV1.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import Foundation
import SwiftData

enum TendoraSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Asset.self,
            MaintenanceTask.self,
            CompletionRecord.self
        ]
    }

    @Model
    final class Asset {
        var id: UUID
        var name: String
        var type: AssetType
        var createdAt: Date
        var notes: String?
        var make: String?
        var model: String?
        var year: Int?
        var fuelType: String?
        var odometer: Double?
        var registrationNumber: String?
        var address: String?
        @Relationship(deleteRule: .cascade, inverse: \MaintenanceTask.asset)
        var tasks: [MaintenanceTask]

        init(
            id: UUID = UUID(),
            name: String,
            type: AssetType,
            createdAt: Date = .now,
            notes: String? = nil,
            make: String? = nil,
            model: String? = nil,
            year: Int? = nil,
            fuelType: String? = nil,
            odometer: Double? = nil,
            registrationNumber: String? = nil,
            address: String? = nil,
            tasks: [MaintenanceTask] = []
        ) {
            self.id = id
            self.name = name
            self.type = type
            self.createdAt = createdAt
            self.notes = notes
            self.make = make
            self.model = model
            self.year = year
            self.fuelType = fuelType
            self.odometer = odometer
            self.registrationNumber = registrationNumber
            self.address = address
            self.tasks = tasks
        }
    }

    @Model
    final class MaintenanceTask {
        var id: UUID
        var title: String
        var createdAt: Date
        var dueDate: Date
        var notes: String?
        var isCompleted: Bool
        var repeatRule: RepeatRule
        var customRepeatValue: Int?
        var customRepeatUnit: RepeatUnit?
        var reminderEnabled: Bool
        var reminderOffset: ReminderOffset
        var asset: Asset?
        @Relationship(deleteRule: .cascade, inverse: \CompletionRecord.task)
        var completionRecords: [CompletionRecord]

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
            completionRecords: [CompletionRecord] = []
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
        }
    }

    @Model
    final class CompletionRecord {
        var id: UUID
        var completedAt: Date
        var notes: String?
        var task: MaintenanceTask?

        init(
            id: UUID = UUID(),
            completedAt: Date = .now,
            notes: String? = nil,
            task: MaintenanceTask? = nil
        ) {
            self.id = id
            self.completedAt = completedAt
            self.notes = notes
            self.task = task
        }
    }
}
