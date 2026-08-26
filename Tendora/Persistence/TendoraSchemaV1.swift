//
//  TendoraSchemaV1.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

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
}
