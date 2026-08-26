//
//  TendoraMigrationPlan.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import SwiftData

enum TendoraMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            TendoraSchemaV1.self,
            TendoraSchemaV2.self
        ]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: TendoraSchemaV1.self, toVersion: TendoraSchemaV2.self)
        ]
    }
}
