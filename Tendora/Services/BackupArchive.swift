//
//  BackupArchive.swift
//  Tendora
//
//  Created by Codex on 06/10/2026.
//

import Foundation

struct TendoraBackupArchive: Codable {
    let formatVersion: Int
    let exportedAt: Date
    let appVersion: String
    let appBuild: String
    let assets: [AssetBackupRecord]
    let tasks: [TaskBackupRecord]
    let completionRecords: [CompletionRecordBackupRecord]
    let attachments: [AttachmentBackupRecord]

    var summary: BackupArchiveSummary {
        BackupArchiveSummary(
            assetCount: assets.count,
            taskCount: tasks.count,
            completionRecordCount: completionRecords.count,
            attachmentCount: attachments.count
        )
    }
}

struct BackupArchiveSummary: Equatable {
    let assetCount: Int
    let taskCount: Int
    let completionRecordCount: Int
    let attachmentCount: Int
}

struct AssetBackupRecord: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: AssetType
    let createdAt: Date
    let notes: String?
    let make: String?
    let model: String?
    let year: Int?
    let fuelType: String?
    let odometer: Double?
    let registrationNumber: String?
    let address: String?
}

struct TaskBackupRecord: Codable, Identifiable {
    let id: UUID
    let title: String
    let createdAt: Date
    let dueDate: Date
    let notes: String?
    let isCompleted: Bool
    let repeatRule: RepeatRule
    let customRepeatValue: Int?
    let customRepeatUnit: RepeatUnit?
    let reminderEnabled: Bool
    let reminderOffset: ReminderOffset
    let assetID: UUID?
}

struct CompletionRecordBackupRecord: Codable, Identifiable {
    let id: UUID
    let completedAt: Date
    let notes: String?
    let taskID: UUID
}

struct AttachmentBackupRecord: Codable, Identifiable {
    let id: UUID
    let createdAt: Date
    let type: AttachmentType
    let displayName: String
    let fileName: String
    let fileData: Data?
    let contentTypeIdentifier: String?
    let assetID: UUID?
    let taskID: UUID?
}
