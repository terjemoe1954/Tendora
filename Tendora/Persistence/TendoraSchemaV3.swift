//
//  TendoraSchemaV3.swift
//  Tendora
//
//  Created by Codex on 05/09/2026.
//

import SwiftData

enum TendoraSchemaV3: VersionedSchema {
    static let versionIdentifier = Schema.Version(3, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Asset.self,
            MaintenanceTask.self,
            CompletionRecord.self,
            Attachment.self
        ]
    }
}
