//
//  CompletionRecord.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import Foundation
import SwiftData

@Model
final class CompletionRecord {
    var id: UUID
    var completedAt: Date
    var notes: String?
    var task: MaintenanceTask?

    init(
        id: UUID = UUID(),
        completedAt: Date = .now,
        notes: String? = nil,
        task: MaintenanceTask? = nil
    ) {
        self.id = id
        self.completedAt = completedAt
        self.notes = notes
        self.task = task
    }
}
