//
//  DemoDataManager.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import SwiftData
import SwiftUI
import UIKit

@MainActor
final class DemoDataManager {
    static let shared = DemoDataManager()

    private let fileManager = FileManager.default

    private init() {}

    func loadScreenshotDemoData(into context: ModelContext) throws {
        try clearAllLocalData(from: context)

        let home = Asset(
            name: "Home",
            type: .home,
            year: 2018,
            address: "Fjordveien 12, Oslo"
        )
        let cabin = Asset(
            name: "Cabin",
            type: .cabin,
            year: 2009,
            address: "Bjørkelia 7, Hemsedal"
        )
        let volvo = Asset(
            name: "Volvo XC60",
            type: .car,
            make: "Volvo",
            model: "XC60",
            year: 2022,
            fuelType: "Hybrid",
            odometer: 42850,
            registrationNumber: "EV 48291"
        )
        let raptor = Asset(
            name: "Raptor",
            type: .boat,
            make: "Raptor",
            model: "260",
            year: 2020
        )
        let garage = Asset(
            name: "Garage",
            type: .other,
            notes: "Storage, tools, and seasonal equipment"
        )

        let assets = [home, cabin, volvo, raptor, garage]
        assets.forEach { context.insert($0) }

        let tasks = [
            MaintenanceTask(
                title: "HVAC service",
                dueDate: date(2026, 9, 3),
                notes: "Book technician and replace filters",
                repeatRule: .sixMonths,
                reminderEnabled: true,
                reminderOffset: .oneWeekBefore,
                asset: home
            ),
            MaintenanceTask(
                title: "Smoke alarm check",
                dueDate: date(2026, 8, 28),
                notes: "Test all units and replace batteries if needed",
                repeatRule: .monthly,
                reminderEnabled: true,
                reminderOffset: .oneDayBefore,
                asset: home
            ),
            MaintenanceTask(
                title: "Gutter cleaning",
                dueDate: date(2026, 10, 5),
                notes: "Check north side first",
                repeatRule: .yearly,
                reminderEnabled: true,
                reminderOffset: .oneWeekBefore,
                asset: home
            ),
            MaintenanceTask(
                title: "Roof inspection",
                dueDate: date(2026, 9, 18),
                notes: "Inspect after summer storms",
                repeatRule: .yearly,
                reminderEnabled: true,
                reminderOffset: .oneWeekBefore,
                asset: cabin
            ),
            MaintenanceTask(
                title: "Chimney cleaning",
                dueDate: date(2026, 11, 2),
                notes: "Confirm booking with local service",
                repeatRule: .yearly,
                reminderEnabled: true,
                reminderOffset: .twoWeeksBefore,
                asset: cabin
            ),
            MaintenanceTask(
                title: "Oil change",
                dueDate: date(2026, 8, 30),
                notes: "Use OEM filter",
                repeatRule: .threeMonths,
                reminderEnabled: true,
                reminderOffset: .oneWeekBefore,
                asset: volvo
            ),
            MaintenanceTask(
                title: "Winter tire swap",
                dueDate: date(2026, 10, 15),
                notes: "Check tread depth before install",
                repeatRule: .yearly,
                reminderEnabled: true,
                reminderOffset: .twoWeeksBefore,
                asset: volvo
            ),
            MaintenanceTask(
                title: "Annual service",
                dueDate: date(2026, 11, 20),
                notes: "Ask dealer to inspect brakes",
                repeatRule: .yearly,
                reminderEnabled: true,
                reminderOffset: .oneMonthBefore,
                asset: volvo
            ),
            MaintenanceTask(
                title: "Engine service",
                dueDate: date(2026, 9, 10),
                notes: "Change oil and inspect cooling system",
                repeatRule: .yearly,
                reminderEnabled: true,
                reminderOffset: .twoWeeksBefore,
                asset: raptor
            ),
            MaintenanceTask(
                title: "Hull cleaning",
                dueDate: date(2026, 8, 27),
                notes: "Wash and inspect below waterline",
                repeatRule: .monthly,
                reminderEnabled: true,
                reminderOffset: .sameDay,
                asset: raptor
            ),
            MaintenanceTask(
                title: "Garage door inspection",
                dueDate: date(2026, 9, 24),
                notes: "Lubricate hinges and test sensors",
                repeatRule: .yearly,
                reminderEnabled: true,
                reminderOffset: .oneWeekBefore,
                asset: garage
            )
        ]

        tasks.forEach { context.insert($0) }

        let history = [
            CompletionRecord(
                completedAt: date(2026, 7, 14),
                notes: "Replaced kitchen and utility room filters",
                task: MaintenanceTask(
                    title: "Water filter replacement",
                    dueDate: date(2027, 7, 14),
                    repeatRule: .yearly,
                    reminderEnabled: false,
                    asset: home
                )
            ),
            CompletionRecord(
                completedAt: date(2026, 8, 8),
                notes: "Adjusted all four tires before road trip",
                task: MaintenanceTask(
                    title: "Tire pressure check",
                    dueDate: date(2026, 9, 8),
                    repeatRule: .monthly,
                    reminderEnabled: false,
                    asset: volvo
                )
            ),
            CompletionRecord(
                completedAt: date(2026, 7, 30),
                notes: "Battery terminals cleaned and tested",
                task: MaintenanceTask(
                    title: "Battery inspection",
                    dueDate: date(2027, 7, 30),
                    repeatRule: .yearly,
                    reminderEnabled: false,
                    asset: raptor
                )
            )
        ]

        for record in history {
            if let task = record.task {
                context.insert(task)
            }
            context.insert(record)
        }

        let generatedAttachments = try [
            makePhotoAttachment(named: "Home Exterior.jpg", asset: home),
            makePDFLikeAttachment(named: "HVAC Warranty.pdf", type: .warranty, asset: home),
            makePDFLikeAttachment(named: "HVAC Service Quote.pdf", type: .serviceRecord, asset: home, task: tasks[0]),
            makePhotoAttachment(named: "Cabin Front.jpg", asset: cabin),
            makePDFLikeAttachment(named: "Volvo Insurance 2026.pdf", type: .insurance, asset: volvo),
            makePDFLikeAttachment(named: "Oil Purchase Receipt.pdf", type: .receipt, asset: volvo),
            makePDFLikeAttachment(named: "Volvo Service Invoice.pdf", type: .serviceRecord, asset: volvo, task: tasks[5]),
            makePhotoAttachment(named: "Raptor at Dock.jpg", asset: raptor),
            makePDFLikeAttachment(named: "Raptor 260 Manual.pdf", type: .manual, asset: raptor)
        ]

        generatedAttachments.forEach { context.insert($0) }

        try context.save()
    }

    func clearAllLocalData(from context: ModelContext) throws {
        let attachments = try context.fetch(FetchDescriptor<Attachment>())
        for attachment in attachments {
            try? AttachmentManager.shared.deleteAttachmentFile(for: attachment)
            context.delete(attachment)
        }

        try context.fetch(FetchDescriptor<CompletionRecord>()).forEach { context.delete($0) }
        try context.fetch(FetchDescriptor<MaintenanceTask>()).forEach { context.delete($0) }
        try context.fetch(FetchDescriptor<Asset>()).forEach { context.delete($0) }

        try context.save()
    }

    private func makePhotoAttachment(named name: String, asset: Asset) throws -> Attachment {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1200, height: 900))
        let image = renderer.image { context in
            let bounds = CGRect(origin: .zero, size: CGSize(width: 1200, height: 900))
            UIColor(red: 0.90, green: 0.94, blue: 1.0, alpha: 1.0).setFill()
            context.fill(bounds)

            let gradientColors = [UIColor.systemPink.cgColor, UIColor.systemIndigo.cgColor] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: [0, 1])!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: bounds.width, y: bounds.height),
                options: []
            )

            let title = NSString(string: name.replacingOccurrences(of: ".jpg", with: ""))
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 68, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            title.draw(at: CGPoint(x: 60, y: 720), withAttributes: attributes)
        }

        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw CocoaError(.fileWriteUnknown)
        }

        return try AttachmentManager.shared.createPhotoAttachment(
            data: data,
            displayName: name,
            asset: asset
        )
    }

    private func makePDFLikeAttachment(
        named name: String,
        type: AttachmentType,
        asset: Asset,
        task: MaintenanceTask? = nil
    ) throws -> Attachment {
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
        let bounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)

        let data = renderer.pdfData { context in
            context.beginPage()

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor.label
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .regular),
                .foregroundColor: UIColor.secondaryLabel
            ]

            NSString(string: name.replacingOccurrences(of: ".pdf", with: "")).draw(
                at: CGPoint(x: 48, y: 64),
                withAttributes: titleAttributes
            )
            NSString(string: "Demo document generated for Tendora App Store screenshots.").draw(
                at: CGPoint(x: 48, y: 120),
                withAttributes: bodyAttributes
            )
            NSString(string: "Linked asset: \(asset.name)").draw(
                at: CGPoint(x: 48, y: 170),
                withAttributes: bodyAttributes
            )
            if let task {
                NSString(string: "Linked task: \(task.title)").draw(
                    at: CGPoint(x: 48, y: 205),
                    withAttributes: bodyAttributes
                )
            }
        }

        try data.write(to: tempURL, options: .atomic)
        defer { try? fileManager.removeItem(at: tempURL) }

        return try AttachmentManager.shared.createFileAttachment(
            from: tempURL,
            type: type,
            asset: asset,
            task: task
        )
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? .now
    }
}
