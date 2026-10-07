//
//  ReportsPDFService.swift
//  Tendora
//
//  Created by Codex on 07/10/2026.
//

import Foundation
import UIKit

struct ReportsPDFService {
    func makeReport(
        assets: [Asset],
        upcomingTasks: [MaintenanceTask],
        overdueTasks: [MaintenanceTask],
        completionRecords: [CompletionRecord],
        missingDocumentAssets: [Asset],
        locale: Locale
    ) throws -> URL {
        let pageBounds = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(reportFilename())

        try renderer.writePDF(to: fileURL) { context in
            var cursorY: CGFloat = 0
            let margin: CGFloat = 44
            let contentWidth = pageBounds.width - (margin * 2)

            func startPage() {
                context.beginPage()
                cursorY = margin
            }

            func ensureSpace(_ height: CGFloat) {
                if cursorY + height > pageBounds.height - margin {
                    startPage()
                }
            }

            func drawText(_ text: String, font: UIFont, color: UIColor = .black, spacingAfter: CGFloat = 8) {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byWordWrapping
                paragraphStyle.alignment = .natural

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraphStyle
                ]
                let attributedText = NSAttributedString(string: text, attributes: attributes)
                let size = attributedText.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                ).integral.size

                ensureSpace(size.height + spacingAfter)
                attributedText.draw(in: CGRect(x: margin, y: cursorY, width: contentWidth, height: size.height))
                cursorY += size.height + spacingAfter
            }

            func drawSectionTitle(_ key: String) {
                cursorY += 10
                drawText(String(localized: String.LocalizationValue(key), locale: locale), font: .boldSystemFont(ofSize: 16), spacingAfter: 10)
            }

            func drawEmpty(_ key: String) {
                drawText(String(localized: String.LocalizationValue(key), locale: locale), font: .systemFont(ofSize: 11), color: .darkGray)
            }

            startPage()

            drawText(String(localized: "reports.pdf.title", locale: locale), font: .boldSystemFont(ofSize: 24), spacingAfter: 6)
            let generatedFormat = String(localized: "reports.pdf.generated_format", locale: locale)
            let generatedDate = Date.now.formatted(.dateTime.locale(locale).day().month().year().hour().minute())
            drawText(String(format: generatedFormat, locale: locale, generatedDate), font: .systemFont(ofSize: 11), color: .darkGray, spacingAfter: 18)

            drawSectionTitle("reports.pdf.section.summary")
            drawText(summaryLine(key: "reports.pdf.summary.assets", count: assets.count, locale: locale), font: .systemFont(ofSize: 12), spacingAfter: 4)
            drawText(summaryLine(key: "reports.pdf.summary.upcoming", count: upcomingTasks.count, locale: locale), font: .systemFont(ofSize: 12), spacingAfter: 4)
            drawText(summaryLine(key: "reports.pdf.summary.overdue", count: overdueTasks.count, locale: locale), font: .systemFont(ofSize: 12), spacingAfter: 4)
            drawText(summaryLine(key: "reports.pdf.summary.missing_documents", count: missingDocumentAssets.count, locale: locale), font: .systemFont(ofSize: 12), spacingAfter: 4)

            drawSectionTitle("reports.pdf.section.contents")
            if assets.isEmpty {
                drawEmpty("reports.pdf.empty.assets")
            } else {
                for asset in assets {
                    drawText(assetLine(asset, locale: locale), font: .systemFont(ofSize: 11), spacingAfter: 5)
                }
            }

            drawSectionTitle("reports.section.overdue")
            if overdueTasks.isEmpty {
                drawEmpty("reports.empty.overdue.message")
            } else {
                for task in overdueTasks {
                    drawText(taskLine(task, locale: locale), font: .systemFont(ofSize: 11), spacingAfter: 5)
                }
            }

            drawSectionTitle("reports.section.upcoming_30_days")
            if upcomingTasks.isEmpty {
                drawEmpty("reports.empty.upcoming.message")
            } else {
                for task in upcomingTasks {
                    drawText(taskLine(task, locale: locale), font: .systemFont(ofSize: 11), spacingAfter: 5)
                }
            }

            drawSectionTitle("reports.section.service_history")
            if completionRecords.isEmpty {
                drawEmpty("reports.empty.history.message")
            } else {
                for record in completionRecords {
                    drawText(historyLine(record, locale: locale), font: .systemFont(ofSize: 11), spacingAfter: 5)
                }
            }

            drawSectionTitle("reports.section.missing_documents")
            if missingDocumentAssets.isEmpty {
                drawEmpty("reports.empty.missing_documents.message")
            } else {
                for asset in missingDocumentAssets {
                    drawText(asset.name, font: .systemFont(ofSize: 11), spacingAfter: 5)
                }
            }
        }

        return fileURL
    }

    private func reportFilename() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        return "Tendora-Report-\(formatter.string(from: .now)).pdf"
    }

    private func summaryLine(key: String, count: Int, locale: Locale) -> String {
        let format = String(localized: String.LocalizationValue(key), locale: locale)
        return String(format: format, locale: locale, count)
    }

    private func assetLine(_ asset: Asset, locale: Locale) -> String {
        let format = String(localized: "reports.pdf.asset_line", locale: locale)
        let activeTaskCount = (asset.tasks ?? []).filter { $0.isCompleted == false }.count
        let attachmentCount = (asset.attachments ?? []).count
        return String(
            format: format,
            locale: locale,
            asset.name,
            asset.type.displayName(locale: locale),
            activeTaskCount,
            attachmentCount
        )
    }

    private func taskLine(_ task: MaintenanceTask, locale: Locale) -> String {
        let format = String(localized: "reports.pdf.task_line", locale: locale)
        let assetName = task.asset?.name ?? String(localized: "reports.asset_unknown", locale: locale)
        let dueDate = task.dueDate.formatted(.dateTime.locale(locale).day().month().year())
        return String(format: format, locale: locale, task.title, assetName, dueDate)
    }

    private func historyLine(_ record: CompletionRecord, locale: Locale) -> String {
        let format = String(localized: "reports.pdf.history_line", locale: locale)
        let taskTitle = record.task?.title ?? String(localized: "reports.task_unknown", locale: locale)
        let assetName = record.task?.asset?.name ?? String(localized: "reports.asset_unknown", locale: locale)
        let completedDate = record.completedAt.formatted(.dateTime.locale(locale).day().month().year())
        return String(format: format, locale: locale, taskTitle, assetName, completedDate)
    }
}

private extension AssetType {
    func displayName(locale: Locale) -> String {
        String(localized: String.LocalizationValue(displayNameLocalizationKey), locale: locale)
    }
}
