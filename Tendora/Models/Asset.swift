//
//  Asset.swift
//  Tendora
//
//  Created by Terje Moe on 22/08/2026.
//

import Foundation
import SwiftData

@Model
final class Asset {
    var id: UUID = UUID()
    var name: String = ""
    var type: AssetType = AssetType.home
    var createdAt: Date = Date.now
    var notes: String?
    var make: String?
    var model: String?
    var year: Int?
    var fuelType: String?
    var odometer: Double?
    var registrationNumber: String?
    var address: String?
    @Relationship(deleteRule: .cascade, inverse: \MaintenanceTask.asset)
    var tasks: [MaintenanceTask]? = []
    @Relationship(deleteRule: .cascade, inverse: \Attachment.asset)
    var attachments: [Attachment]? = []

    init(
        id: UUID = UUID(),
        name: String,
        type: AssetType,
        createdAt: Date = .now,
        notes: String? = nil,
        make: String? = nil,
        model: String? = nil,
        year: Int? = nil,
        fuelType: String? = nil,
        odometer: Double? = nil,
        registrationNumber: String? = nil,
        address: String? = nil,
        tasks: [MaintenanceTask] = [],
        attachments: [Attachment] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.createdAt = createdAt
        self.notes = notes
        self.make = make
        self.model = model
        self.year = year
        self.fuelType = fuelType
        self.odometer = odometer
        self.registrationNumber = registrationNumber
        self.address = address
        self.tasks = tasks
        self.attachments = attachments
    }
}
