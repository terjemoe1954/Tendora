//
//  BackupRestoreService.swift
//  Tendora
//
//  Created by Codex on 06/10/2026.
//

import Foundation
import SwiftData

@MainActor
final class BackupRestoreService {
    static let shared = BackupRestoreService()

    static let currentFormatVersion = 1
    static let backupFileExtension = "tendorabackup"

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func makeArchive(from modelContext: ModelContext, includeAttachments: Bool = true) throws -> TendoraBackupArchive {
        let assets = try modelContext.fetch(FetchDescriptor<Asset>())
        let tasks = try modelContext.fetch(FetchDescriptor<MaintenanceTask>())
        let completionRecords = try modelContext.fetch(FetchDescriptor<CompletionRecord>())
        let attachments = try modelContext.fetch(FetchDescriptor<Attachment>())

        return TendoraBackupArchive(
            formatVersion: Self.currentFormatVersion,
            exportedAt: .now,
            appVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown",
            appBuild: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown",
            assets: assets.map(Self.assetRecord),
            tasks: tasks.map(Self.taskRecord),
            completionRecords: completionRecords.compactMap(Self.completionRecord),
            attachments: attachments.map { Self.attachmentRecord($0, includeFileData: includeAttachments) }
        )
    }

    func encodedArchive(from modelContext: ModelContext, includeAttachments: Bool = true) throws -> Data {
        try encoder.encode(makeArchive(from: modelContext, includeAttachments: includeAttachments))
    }

    func archive(from data: Data) throws -> TendoraBackupArchive {
        let archive = try decoder.decode(TendoraBackupArchive.self, from: data)
        try validate(archive)
        return archive
    }

    func validate(_ archive: TendoraBackupArchive) throws {
        guard archive.formatVersion <= Self.currentFormatVersion else {
            throw BackupRestoreError.unsupportedFormatVersion(archive.formatVersion)
        }

        let assetIDs = Set(archive.assets.map(\.id))
        let taskIDs = Set(archive.tasks.map(\.id))

        for task in archive.tasks {
            if let assetID = task.assetID, assetIDs.contains(assetID) == false {
                throw BackupRestoreError.missingAssetForTask(taskID: task.id, assetID: assetID)
            }
        }

        for completionRecord in archive.completionRecords where taskIDs.contains(completionRecord.taskID) == false {
            throw BackupRestoreError.missingTaskForCompletionRecord(recordID: completionRecord.id, taskID: completionRecord.taskID)
        }

        for attachment in archive.attachments {
            if let assetID = attachment.assetID, assetIDs.contains(assetID) == false {
                throw BackupRestoreError.missingAssetForAttachment(attachmentID: attachment.id, assetID: assetID)
            }

            if let taskID = attachment.taskID, taskIDs.contains(taskID) == false {
                throw BackupRestoreError.missingTaskForAttachment(attachmentID: attachment.id, taskID: taskID)
            }
        }
    }

    func restore(_ archive: TendoraBackupArchive, into modelContext: ModelContext) throws -> BackupArchiveSummary {
        try validate(archive)
        try deleteCurrentData(in: modelContext)

        var assetsByID: [UUID: Asset] = [:]
        var tasksByID: [UUID: MaintenanceTask] = [:]

        for record in archive.assets {
            let asset = Asset(
                id: record.id,
                name: record.name,
                type: record.type,
                createdAt: record.createdAt,
                notes: record.notes,
                make: record.make,
                model: record.model,
                year: record.year,
                fuelType: record.fuelType,
                odometer: record.odometer,
                registrationNumber: record.registrationNumber,
                address: record.address
            )
            assetsByID[record.id] = asset
            modelContext.insert(asset)
        }

        for record in archive.tasks {
            let task = MaintenanceTask(
                id: record.id,
                title: record.title,
                createdAt: record.createdAt,
                dueDate: record.dueDate,
                notes: record.notes,
                isCompleted: record.isCompleted,
                repeatRule: record.repeatRule,
                customRepeatValue: record.customRepeatValue,
                customRepeatUnit: record.customRepeatUnit,
                reminderEnabled: record.reminderEnabled,
                reminderOffset: record.reminderOffset,
                asset: record.assetID.flatMap { assetsByID[$0] }
            )
            tasksByID[record.id] = task
            modelContext.insert(task)
        }

        for record in archive.completionRecords {
            let completionRecord = CompletionRecord(
                id: record.id,
                completedAt: record.completedAt,
                notes: record.notes,
                task: tasksByID[record.taskID]
            )
            modelContext.insert(completionRecord)
        }

        var restoredAttachments: [Attachment] = []
        for record in archive.attachments {
            let attachment = Attachment(
                id: record.id,
                createdAt: record.createdAt,
                type: record.type,
                displayName: record.displayName,
                fileName: record.fileName,
                fileData: record.fileData,
                contentTypeIdentifier: record.contentTypeIdentifier,
                asset: record.assetID.flatMap { assetsByID[$0] },
                task: record.taskID.flatMap { tasksByID[$0] }
            )
            restoredAttachments.append(attachment)
            modelContext.insert(attachment)
        }

        try modelContext.save()
        recreateLocalAttachmentFiles(restoredAttachments)
        return archive.summary
    }

    private func deleteCurrentData(in modelContext: ModelContext) throws {
        for attachment in try modelContext.fetch(FetchDescriptor<Attachment>()) {
            try? AttachmentManager.shared.deleteAttachmentFile(for: attachment)
            modelContext.delete(attachment)
        }

        for completionRecord in try modelContext.fetch(FetchDescriptor<CompletionRecord>()) {
            modelContext.delete(completionRecord)
        }

        for task in try modelContext.fetch(FetchDescriptor<MaintenanceTask>()) {
            modelContext.delete(task)
        }

        for asset in try modelContext.fetch(FetchDescriptor<Asset>()) {
            modelContext.delete(asset)
        }

        try modelContext.save()
    }

    private func recreateLocalAttachmentFiles(_ attachments: [Attachment]) {
        for attachment in attachments where attachment.fileData != nil {
            _ = try? AttachmentManager.shared.fileURL(for: attachment)
        }
    }

    private static func assetRecord(_ asset: Asset) -> AssetBackupRecord {
        AssetBackupRecord(
            id: asset.id,
            name: asset.name,
            type: asset.type,
            createdAt: asset.createdAt,
            notes: asset.notes,
            make: asset.make,
            model: asset.model,
            year: asset.year,
            fuelType: asset.fuelType,
            odometer: asset.odometer,
            registrationNumber: asset.registrationNumber,
            address: asset.address
        )
    }

    private static func taskRecord(_ task: MaintenanceTask) -> TaskBackupRecord {
        TaskBackupRecord(
            id: task.id,
            title: task.title,
            createdAt: task.createdAt,
            dueDate: task.dueDate,
            notes: task.notes,
            isCompleted: task.isCompleted,
            repeatRule: task.repeatRule,
            customRepeatValue: task.customRepeatValue,
            customRepeatUnit: task.customRepeatUnit,
            reminderEnabled: task.reminderEnabled,
            reminderOffset: task.reminderOffset,
            assetID: task.asset?.id
        )
    }

    private static func completionRecord(_ record: CompletionRecord) -> CompletionRecordBackupRecord? {
        guard let taskID = record.task?.id else {
            return nil
        }

        return CompletionRecordBackupRecord(
            id: record.id,
            completedAt: record.completedAt,
            notes: record.notes,
            taskID: taskID
        )
    }

    private static func attachmentRecord(_ attachment: Attachment, includeFileData: Bool) -> AttachmentBackupRecord {
        AttachmentBackupRecord(
            id: attachment.id,
            createdAt: attachment.createdAt,
            type: attachment.type,
            displayName: attachment.displayName,
            fileName: attachment.fileName,
            fileData: includeFileData ? attachment.fileData : nil,
            contentTypeIdentifier: attachment.contentTypeIdentifier,
            assetID: attachment.asset?.id,
            taskID: attachment.task?.id
        )
    }
}

enum BackupRestoreError: LocalizedError {
    case unsupportedFormatVersion(Int)
    case missingAssetForTask(taskID: UUID, assetID: UUID)
    case missingAssetForAttachment(attachmentID: UUID, assetID: UUID)
    case missingTaskForCompletionRecord(recordID: UUID, taskID: UUID)
    case missingTaskForAttachment(attachmentID: UUID, taskID: UUID)

    var errorDescription: String? {
        switch self {
        case .unsupportedFormatVersion(let version):
            return "Unsupported Tendora backup format version: \(version)."
        case .missingAssetForTask(let taskID, let assetID):
            return "Backup task \(taskID.uuidString) references missing asset \(assetID.uuidString)."
        case .missingAssetForAttachment(let attachmentID, let assetID):
            return "Backup attachment \(attachmentID.uuidString) references missing asset \(assetID.uuidString)."
        case .missingTaskForCompletionRecord(let recordID, let taskID):
            return "Backup completion record \(recordID.uuidString) references missing task \(taskID.uuidString)."
        case .missingTaskForAttachment(let attachmentID, let taskID):
            return "Backup attachment \(attachmentID.uuidString) references missing task \(taskID.uuidString)."
        }
    }
}
