//
//  ReportsView.swift
//  Tendora
//
//  Created by Codex on 07/10/2026.
//

import SwiftData
import SwiftUI

struct ReportsView: View {
    @Environment(\.locale) private var locale

    @Query(sort: \MaintenanceTask.dueDate, order: .forward) private var tasks: [MaintenanceTask]
    @Query(sort: \Asset.name, order: .forward) private var assets: [Asset]
    @Query(sort: \CompletionRecord.completedAt, order: .reverse) private var completionRecords: [CompletionRecord]
    @State private var shareItem: AttachmentShareItem?
    @State private var exportError: ReportExportError?

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ReportsSummarySection(
                    upcomingCount: upcomingTasks.count,
                    overdueCount: overdueTasks.count,
                    missingDocumentCount: assetsMissingDocuments.count,
                    historyCount: completionRecords.count
                )

                TaskReportSection(
                    titleKey: "reports.section.upcoming_30_days",
                    emptyTitleKey: "reports.empty.upcoming.title",
                    emptyMessageKey: "reports.empty.upcoming.message",
                    tasks: upcomingTasks,
                    statusStyle: .upcoming
                )

                TaskReportSection(
                    titleKey: "reports.section.overdue",
                    emptyTitleKey: "reports.empty.overdue.title",
                    emptyMessageKey: "reports.empty.overdue.message",
                    tasks: overdueTasks,
                    statusStyle: .overdue
                )

                ServiceHistoryReportSection(records: recentCompletionRecords)
                MissingDocumentsReportSection(assets: assetsMissingDocuments)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("reports.title")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    exportPDFReport()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("reports.pdf.share")
            }
        }
        .sheet(item: $shareItem) { item in
            AttachmentShareSheetView(fileURL: item.url)
        }
        .alert(item: $exportError) { error in
            Alert(
                title: Text("reports.pdf.error.title"),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var activeTasks: [MaintenanceTask] {
        tasks.filter { $0.isCompleted == false }
    }

    private var startOfToday: Date {
        calendar.startOfDay(for: .now)
    }

    private var upcomingCutoffDate: Date {
        calendar.date(byAdding: .day, value: 30, to: startOfToday) ?? .now
    }

    private var upcomingTasks: [MaintenanceTask] {
        activeTasks.filter { task in
            task.dueDate >= startOfToday && task.dueDate <= upcomingCutoffDate
        }
    }

    private var overdueTasks: [MaintenanceTask] {
        activeTasks.filter { $0.dueDate < startOfToday }
    }

    private var recentCompletionRecords: [CompletionRecord] {
        Array(completionRecords.prefix(12))
    }

    private var assetsMissingDocuments: [Asset] {
        assets.filter { asset in
            let assetAttachments = asset.attachments ?? []
            let taskAttachments = (asset.tasks ?? []).flatMap { $0.attachments ?? [] }
            return assetAttachments.isEmpty && taskAttachments.isEmpty
        }
    }

    private func exportPDFReport() {
        do {
            let fileURL = try ReportsPDFService().makeReport(
                assets: assets,
                upcomingTasks: upcomingTasks,
                overdueTasks: overdueTasks,
                completionRecords: recentCompletionRecords,
                missingDocumentAssets: assetsMissingDocuments,
                locale: locale
            )
            shareItem = AttachmentShareItem(url: fileURL)
        } catch {
            exportError = ReportExportError(message: error.localizedDescription)
        }
    }
}

private struct ReportExportError: Identifiable {
    let id = UUID()
    let message: String
}

private struct ReportsSummarySection: View {
    let upcomingCount: Int
    let overdueCount: Int
    let missingDocumentCount: Int
    let historyCount: Int

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ReportMetricCard(
                titleKey: "reports.summary.upcoming",
                value: upcomingCount,
                systemImage: "calendar.badge.clock",
                color: .blue
            )
            ReportMetricCard(
                titleKey: "reports.summary.overdue",
                value: overdueCount,
                systemImage: "exclamationmark.triangle.fill",
                color: .red
            )
            ReportMetricCard(
                titleKey: "reports.summary.missing_documents",
                value: missingDocumentCount,
                systemImage: "doc.badge.questionmark",
                color: .orange
            )
            ReportMetricCard(
                titleKey: "reports.summary.history",
                value: historyCount,
                systemImage: "checkmark.seal.fill",
                color: .green
            )
        }
    }
}

private struct ReportMetricCard: View {
    let titleKey: LocalizedStringKey
    let value: Int
    let systemImage: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)

            Text("\(value)")
                .font(.title2.weight(.bold))

            Text(titleKey)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2, reservesSpace: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

private struct TaskReportSection: View {
    let titleKey: LocalizedStringKey
    let emptyTitleKey: LocalizedStringKey
    let emptyMessageKey: LocalizedStringKey
    let tasks: [MaintenanceTask]
    let statusStyle: ReportTaskStatusStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(titleKey)
                .font(.headline)

            if tasks.isEmpty {
                ReportEmptyState(titleKey: emptyTitleKey, messageKey: emptyMessageKey, systemImage: "checkmark.circle")
            } else {
                VStack(spacing: 12) {
                    ForEach(tasks) { task in
                        NavigationLink {
                            TaskDetailView(task: task)
                        } label: {
                            ReportTaskRow(task: task, statusStyle: statusStyle)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private enum ReportTaskStatusStyle {
    case upcoming
    case overdue

    var color: Color {
        switch self {
        case .upcoming:
            return .blue
        case .overdue:
            return .red
        }
    }
}

private struct ReportTaskRow: View {
    @Environment(\.locale) private var locale

    let task: MaintenanceTask
    let statusStyle: ReportTaskStatusStyle

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: statusStyle == .overdue ? "exclamationmark.circle.fill" : "calendar.circle.fill")
                .font(.title3)
                .foregroundStyle(statusStyle.color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 5) {
                Text(task.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(task.asset?.name ?? String(localized: "reports.asset_unknown", locale: locale))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(dueDateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var dueDateText: String {
        let format = String(localized: "reports.due_format", locale: locale)
        let dueDate = task.dueDate.formatted(.dateTime.locale(locale).day().month().year())
        return String(format: format, locale: locale, dueDate)
    }
}

private struct ServiceHistoryReportSection: View {
    let records: [CompletionRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("reports.section.service_history")
                .font(.headline)

            if records.isEmpty {
                ReportEmptyState(
                    titleKey: "reports.empty.history.title",
                    messageKey: "reports.empty.history.message",
                    systemImage: "clock.arrow.circlepath"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(records) { record in
                        if let task = record.task {
                            NavigationLink {
                                TaskDetailView(task: task)
                            } label: {
                                ServiceHistoryRow(record: record)
                            }
                            .buttonStyle(.plain)
                        } else {
                            ServiceHistoryRow(record: record)
                        }
                    }
                }
            }
        }
    }
}

private struct ServiceHistoryRow: View {
    @Environment(\.locale) private var locale

    let record: CompletionRecord

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title3)
                .foregroundStyle(.green)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 5) {
                Text(record.task?.title ?? String(localized: "reports.task_unknown", locale: locale))
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let assetName = record.task?.asset?.name {
                    Text(assetName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(completedDateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if record.task != nil {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var completedDateText: String {
        let format = String(localized: "reports.completed_format", locale: locale)
        let completedDate = record.completedAt.formatted(.dateTime.locale(locale).day().month().year())
        return String(format: format, locale: locale, completedDate)
    }
}

private struct MissingDocumentsReportSection: View {
    let assets: [Asset]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("reports.section.missing_documents")
                .font(.headline)

            if assets.isEmpty {
                ReportEmptyState(
                    titleKey: "reports.empty.missing_documents.title",
                    messageKey: "reports.empty.missing_documents.message",
                    systemImage: "doc.text.magnifyingglass"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(assets) { asset in
                        NavigationLink {
                            AssetDetailView(asset: asset)
                        } label: {
                            MissingDocumentAssetRow(asset: asset)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct MissingDocumentAssetRow: View {
    let asset: Asset

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: asset.type.symbolName)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 5) {
                Text(asset.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(LocalizedStringKey(asset.type.displayNameLocalizationKey))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

private struct ReportEmptyState: View {
    let titleKey: LocalizedStringKey
    let messageKey: LocalizedStringKey
    let systemImage: String

    var body: some View {
        ContentUnavailableView(
            titleKey,
            systemImage: systemImage,
            description: Text(messageKey)
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}
