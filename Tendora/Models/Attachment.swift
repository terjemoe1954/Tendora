//
//  Attachment.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import Foundation
import SwiftData

@Model
final class Attachment {
    var id: UUID = UUID()
    var createdAt: Date = Date.now
    var type: AttachmentType = AttachmentType.other
    var displayName: String = ""
    var fileName: String = ""
    @Attribute(.externalStorage) var fileData: Data?
    var contentTypeIdentifier: String?
    var asset: Asset?
    var task: MaintenanceTask?

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        type: AttachmentType,
        displayName: String,
        fileName: String,
        fileData: Data? = nil,
        contentTypeIdentifier: String? = nil,
        asset: Asset? = nil,
        task: MaintenanceTask? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.type = type
        self.displayName = displayName
        self.fileName = fileName
        self.fileData = fileData
        self.contentTypeIdentifier = contentTypeIdentifier
        self.asset = asset
        self.task = task
    }
}
