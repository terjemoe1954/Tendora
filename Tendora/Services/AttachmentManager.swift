//
//  AttachmentManager.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import Foundation
import UniformTypeIdentifiers

@MainActor
final class AttachmentManager {
    static let shared = AttachmentManager()

    private let fileManager = FileManager.default

    private init() {}

    func createPhotoAttachment(
        data: Data,
        displayName: String,
        asset: Asset? = nil,
        task: MaintenanceTask? = nil
    ) throws -> Attachment {
        let fileName = "\(UUID().uuidString).jpg"
        let destinationURL = try attachmentsDirectoryURL().appending(path: fileName)
        try data.write(to: destinationURL, options: .atomic)

        return Attachment(
            type: .photo,
            displayName: displayName,
            fileName: fileName,
            contentTypeIdentifier: UTType.jpeg.identifier,
            asset: asset,
            task: task
        )
    }

    func createFileAttachment(
        from sourceURL: URL,
        type: AttachmentType,
        asset: Asset? = nil,
        task: MaintenanceTask? = nil
    ) throws -> Attachment {
        let didAccessSecurityScope = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didAccessSecurityScope {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        let fileExtension = sourceURL.pathExtension
        let fileName = fileExtension.isEmpty
            ? UUID().uuidString
            : "\(UUID().uuidString).\(fileExtension)"

        let destinationURL = try attachmentsDirectoryURL().appending(path: fileName)
        if fileManager.fileExists(atPath: destinationURL.path()) {
            try fileManager.removeItem(at: destinationURL)
        }
        try fileManager.copyItem(at: sourceURL, to: destinationURL)

        let contentTypeIdentifier = try sourceURL.resourceValues(forKeys: [.contentTypeKey]).contentType?.identifier

        return Attachment(
            type: type,
            displayName: sourceURL.lastPathComponent,
            fileName: fileName,
            contentTypeIdentifier: contentTypeIdentifier,
            asset: asset,
            task: task
        )
    }

    func fileURL(for attachment: Attachment) throws -> URL {
        try attachmentsDirectoryURL().appending(path: attachment.fileName)
    }

    func deleteAttachmentFile(for attachment: Attachment) throws {
        let fileURL = try fileURL(for: attachment)
        if fileManager.fileExists(atPath: fileURL.path()) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    private func attachmentsDirectoryURL() throws -> URL {
        let applicationSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directoryURL = applicationSupportURL.appending(path: "Attachments", directoryHint: .isDirectory)

        if fileManager.fileExists(atPath: directoryURL.path()) == false {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }

        return directoryURL
    }
}
