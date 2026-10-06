//
//  TendoraBackupDocument.swift
//  Tendora
//
//  Created by Codex on 06/10/2026.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let tendoraBackup = UTType(exportedAs: "com.terjemoe.tendora.backup", conformingTo: .json)
}

struct TendoraBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.tendoraBackup, .json] }
    static var writableContentTypes: [UTType] { [.tendoraBackup] }

    var data: Data

    init(data: Data = Data()) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
