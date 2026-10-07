//
//  DataResetService.swift
//  Tendora
//
//  Created by Codex on 07/10/2026.
//

import Foundation
import SwiftData

struct DataResetSummary: Equatable {
    let assetCount: Int
    let taskCount: Int
    let completionRecordCount: Int
    let attachmentCount: Int
}

@MainActor
final class DataResetService {
    static let shared = DataResetService()

    private init() {}

    func resetAllUserData(in modelContext: ModelContext) async throws -> DataResetSummary {
        let attachments = try modelContext.fetch(FetchDescriptor<Attachment>())
        let completionRecords = try modelContext.fetch(FetchDescriptor<CompletionRecord>())
        let tasks = try modelContext.fetch(FetchDescriptor<MaintenanceTask>())
        let assets = try modelContext.fetch(FetchDescriptor<Asset>())

        for attachment in attachments {
            try? AttachmentManager.shared.deleteAttachmentFile(for: attachment)
            modelContext.delete(attachment)
        }

        for completionRecord in completionRecords {
            modelContext.delete(completionRecord)
        }

        for task in tasks {
            modelContext.delete(task)
        }

        for asset in assets {
            modelContext.delete(asset)
        }

        try modelContext.save()
        await NotificationManager.shared.cancelAllTaskNotifications()

        return DataResetSummary(
            assetCount: assets.count,
            taskCount: tasks.count,
            completionRecordCount: completionRecords.count,
            attachmentCount: attachments.count
        )
    }
}
