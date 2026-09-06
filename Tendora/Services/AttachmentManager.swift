//
//  AttachmentManager.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import Foundation
import UniformTypeIdentifiers

enum AttachmentFileError: Error {
    case missingFileData
}

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
            fileData: data,
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
        let fileData = try Data(contentsOf: destinationURL)

        let contentTypeIdentifier = try sourceURL.resourceValues(forKeys: [.contentTypeKey]).contentType?.identifier

        return Attachment(
            type: type,
            displayName: sourceURL.lastPathComponent,
            fileName: fileName,
            fileData: fileData,
            contentTypeIdentifier: contentTypeIdentifier,
            asset: asset,
            task: task
        )
    }

    func fileURL(for attachment: Attachment) throws -> URL {
        let fileURL = try localFileURL(for: attachment)
        if fileManager.fileExists(atPath: fileURL.path()) {
            return fileURL
        }

        guard let fileData = attachment.fileData else {
            throw AttachmentFileError.missingFileData
        }

        try fileData.write(to: fileURL, options: .atomic)
        return fileURL
    }

    func deleteAttachmentFile(for attachment: Attachment) throws {
        let fileURL = try localFileURL(for: attachment)
        if fileManager.fileExists(atPath: fileURL.path()) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    func cacheLocalFileDataIfNeeded(for attachment: Attachment) throws -> Bool {
        guard attachment.fileData == nil else {
            return false
        }

        let fileURL = try localFileURL(for: attachment)
        guard fileManager.fileExists(atPath: fileURL.path()) else {
            return false
        }

        attachment.fileData = try Data(contentsOf: fileURL)
        return true
    }

    private func localFileURL(for attachment: Attachment) throws -> URL {
        try attachmentsDirectoryURL().appending(path: attachment.fileName)
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
