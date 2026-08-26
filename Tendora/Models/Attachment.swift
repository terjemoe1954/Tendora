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
    var id: UUID
    var createdAt: Date
    var type: AttachmentType
    var displayName: String
    var fileName: String
    var contentTypeIdentifier: String?
    var asset: Asset?
    var task: MaintenanceTask?

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        type: AttachmentType,
        displayName: String,
        fileName: String,
        contentTypeIdentifier: String? = nil,
        asset: Asset? = nil,
        task: MaintenanceTask? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.type = type
        self.displayName = displayName
        self.fileName = fileName
        self.contentTypeIdentifier = contentTypeIdentifier
        self.asset = asset
        self.task = task
    }
}
