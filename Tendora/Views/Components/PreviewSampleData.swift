//
//  PreviewSampleData.swift
//  Tendora
//
//  Created by Terje Moe on 22/08/2026.
//

import Foundation
import SwiftData

enum PreviewSampleData {
    static let home = Asset(
            name: "Hjem",
            type: .home,
            notes: "Familiens Hjem",
            year: 2017,
            address: "Bekkedroga 16"
        )

    static let truck = Asset(
            name: "Ford F150",
            type: .car,
            make: "Ford",
            model: "F150",
            year: 2022,
            fuelType: "V8 Diesel",
            odometer: 28450,
            registrationNumber: "AB12345"
        )

    static let assets: [Asset] = [
        home,
        truck
    ]

    static let tasks: [MaintenanceTask] = [
        MaintenanceTask(
            title: "Smoke detector check",
            dueDate: Calendar.current.date(byAdding: .day, value: 5, to: .now) ?? .now,
            repeatRule: .yearly,
            asset: home
        ),
        MaintenanceTask(
            title: "Car service",
            dueDate: Calendar.current.date(byAdding: .day, value: 14, to: .now) ?? .now,
            notes: "Book annual service at the dealer.",
            repeatRule: .yearly,
            asset: truck
        )
    ]

    static let attachments: [Attachment] = [
        Attachment(
            type: .manual,
            displayName: "Heat Pump Manual.pdf",
            fileName: "preview-manual.pdf",
            asset: home
        ),
        Attachment(
            type: .serviceRecord,
            displayName: "Annual Service Receipt.pdf",
            fileName: "preview-receipt.pdf",
            asset: truck,
            task: tasks[1]
        )
    ]

    static let container: ModelContainer = {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(
                for: Asset.self,
                MaintenanceTask.self,
                CompletionRecord.self,
                Attachment.self,
                configurations: configuration
            )
            assets.forEach { container.mainContext.insert($0) }
            tasks.forEach { container.mainContext.insert($0) }
            attachments.forEach { container.mainContext.insert($0) }
            return container
        } catch {
            fatalError("Unable to create preview container: \(error)")
        }
    }()
}
