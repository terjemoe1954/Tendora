//
//  AssetDetailView.swift
//  Tendora
//
//  Created by Terje Moe on 22/08/2026.
//

import SwiftData
import SwiftUI

struct AssetDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let asset: Asset
    @State private var isPresentingAddTask = false
    @State private var isPresentingAddAttachment = false
    @State private var isPresentingEditAsset = false
    @State private var isShowingDeleteAssetConfirmation = false
    @State private var attachmentPendingDeletion: Attachment?
    @State private var previewItem: AttachmentPreviewItem?
    @State private var shareItem: AttachmentShareItem?
    @State private var alertState: AppAlertState?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerCard
                tasksSection
                attachmentsSection
                historySection
                infoSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(asset.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        isPresentingAddTask = true
                    } label: {
                        Label("asset_detail.add_task", systemImage: "plus")
                    }

                    Button {
                        isPresentingEditAsset = true
                    } label: {
                        Label("asset_detail.edit_asset", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        isShowingDeleteAssetConfirmation = true
                    } label: {
                        Label("asset_detail.delete_asset", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isPresentingAddTask) {
            AddTaskView(asset: asset)
        }
        .sheet(isPresented: $isPresentingEditAsset) {
            AddAssetView(assetToEdit: asset)
        }
        .sheet(isPresented: $isPresentingAddAttachment) {
            AddAttachmentView(asset: asset, task: nil)
        }
        .confirmationDialog("asset_detail.delete_asset_confirmation", isPresented: $isShowingDeleteAssetConfirmation, titleVisibility: .visible) {
            Button("asset_detail.delete_asset", role: .destructive) {
                deleteAsset()
            }
            Button("common.cancel", role: .cancel) {}
        }
        .confirmationDialog("attachment.delete.confirmation", isPresented: isShowingAttachmentDeleteConfirmation, titleVisibility: .visible) {
            Button("attachment.delete.action", role: .destructive) {
                guard let attachmentPendingDeletion else { return }
                deleteAttachment(attachmentPendingDeletion)
            }
            Button("common.cancel", role: .cancel) {
                attachmentPendingDeletion = nil
            }
        }
        .alert(item: $alertState) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text(String(localized: "common.ok"))))
        }
        .sheet(item: $previewItem) { item in
            AttachmentPreviewView(fileURL: item.url)
        }
        .sheet(item: $shareItem) { item in
            AttachmentShareSheetView(fileURL: item.url)
        }
    }

    private var headerCard: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 72, height: 72)

                Image(systemName: asset.type.symbolName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(asset.name)
                    .font(.title2.weight(.semibold))

                Text(asset.type.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let metadata = asset.primaryMetadata, metadata != String(localized: "asset.metadata.empty") {
                    Text(metadata)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("asset_detail.section.info")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(asset.detailItems) { item in
                    LabeledContent(item.title, value: item.value)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)

                    if item.id != asset.detailItems.last?.id {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
    }

    private var activeTasks: [MaintenanceTask] {
        asset.tasks
            .filter { $0.isCompleted == false }
            .sorted { $0.dueDate < $1.dueDate }
    }

    private var completionHistory: [(task: MaintenanceTask, record: CompletionRecord)] {
        asset.tasks
            .flatMap { task in
                task.completionRecords.map { (task: task, record: $0) }
            }
            .sorted { $0.record.completedAt > $1.record.completedAt }
    }

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("asset_detail.section.tasks")
                    .font(.headline)

                Spacer()

                Button("asset_detail.add_task") {
                    isPresentingAddTask = true
                }
                .font(.subheadline.weight(.semibold))
            }

            if activeTasks.isEmpty {
                ContentUnavailableView(
                    "asset_detail.tasks.empty_title",
                    systemImage: "checklist",
                    description: Text("asset_detail.tasks.empty_message")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(activeTasks) { task in
                        NavigationLink {
                            TaskDetailView(task: task)
                        } label: {
                            AssetTaskCard(task: task)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("asset_detail.section.documents")
                    .font(.headline)

                Spacer()

                Button("asset_detail.add_document") {
                    isPresentingAddAttachment = true
                }
                .font(.subheadline.weight(.semibold))
            }

            if asset.attachments.isEmpty {
                ContentUnavailableView(
                    "asset_detail.documents.empty_title",
                    systemImage: "doc.text",
                    description: Text("asset_detail.documents.empty_message")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(asset.attachments.sorted { $0.createdAt > $1.createdAt }.prefix(4)) { attachment in
                        AttachmentRowView(
                            attachment: attachment,
                            onOpen: {
                                openAttachment(attachment)
                            },
                            onShare: {
                                shareAttachment(attachment)
                            }
                        ) {
                            attachmentPendingDeletion = attachment
                        }
                    }
                }
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("asset_detail.section.history")
                .font(.headline)

            if completionHistory.isEmpty {
                ContentUnavailableView(
                    "asset_detail.history.empty_title",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("asset_detail.history.empty_message")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(completionHistory.prefix(5).enumerated()), id: \.element.record.id) { index, entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.task.title)
                                .font(.headline)

                            Text(
                                String(
                                    format: String(localized: "asset_detail.history.completed_format"),
                                    locale: .current,
                                    entry.record.completedAt.formatted(date: .abbreviated, time: .omitted)
                                )
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)

                        if index < completionHistory.prefix(5).count - 1 {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            }
        }
    }

    private var isShowingAttachmentDeleteConfirmation: Binding<Bool> {
        Binding(
            get: { attachmentPendingDeletion != nil },
            set: { isPresented in
                if isPresented == false {
                    attachmentPendingDeletion = nil
                }
            }
        )
    }

    private func deleteAsset() {
        for attachment in asset.attachments {
            try? AttachmentManager.shared.deleteAttachmentFile(for: attachment)
        }

        for task in asset.tasks {
            Task {
                await NotificationManager.shared.cancelNotification(for: task)
            }

            for attachment in task.attachments {
                try? AttachmentManager.shared.deleteAttachmentFile(for: attachment)
            }
        }

        modelContext.delete(asset)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertState = AppAlertState(
                title: String(localized: "error.data.title"),
                message: String(localized: "error.data.delete_failed.message")
            )
        }
    }

    private func deleteAttachment(_ attachment: Attachment) {
        do {
            try AttachmentManager.shared.deleteAttachmentFile(for: attachment)
            modelContext.delete(attachment)
            try modelContext.save()
            attachmentPendingDeletion = nil
        } catch {
            alertState = AppAlertState(
                title: String(localized: "error.data.title"),
                message: String(localized: "error.data.delete_failed.message")
            )
        }
    }

    private func openAttachment(_ attachment: Attachment) {
        guard let fileURL = try? AttachmentManager.shared.fileURL(for: attachment) else {
            alertState = AppAlertState(
                title: String(localized: "error.attachments.title"),
                message: String(localized: "error.attachments.open_failed.message")
            )
            return
        }

        previewItem = AttachmentPreviewItem(url: fileURL)
    }

    private func shareAttachment(_ attachment: Attachment) {
        guard let fileURL = try? AttachmentManager.shared.fileURL(for: attachment) else {
            alertState = AppAlertState(
                title: String(localized: "error.attachments.title"),
                message: String(localized: "error.attachments.open_failed.message")
            )
            return
        }

        shareItem = AttachmentShareItem(url: fileURL)
    }
}

private struct AssetDetailItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
}

private extension Asset {
    var detailItems: [AssetDetailItem] {
        var items: [AssetDetailItem] = [
            AssetDetailItem(title: String(localized: "asset_detail.field.asset_type"), value: type.displayName)
        ]

        if let make, make.isEmpty == false {
            items.append(AssetDetailItem(title: String(localized: "asset_detail.field.make"), value: make))
        }

        if let model, model.isEmpty == false {
            items.append(AssetDetailItem(title: String(localized: "asset_detail.field.model"), value: model))
        }

        if let year {
            items.append(AssetDetailItem(title: String(localized: "asset_detail.field.year"), value: String(year)))
        }

        if let fuelType, fuelType.isEmpty == false {
            items.append(AssetDetailItem(title: String(localized: "asset_detail.field.fuel_type"), value: fuelType))
        }

        if let odometer {
            items.append(AssetDetailItem(title: String(localized: "asset_detail.field.odometer"), value: odometer.formatted()))
        }

        if let registrationNumber, registrationNumber.isEmpty == false {
            items.append(AssetDetailItem(title: String(localized: "asset_detail.field.registration"), value: registrationNumber))
        }

        if let address, address.isEmpty == false {
            items.append(AssetDetailItem(title: String(localized: "asset_detail.field.address"), value: address))
        }

        if let notes, notes.isEmpty == false {
            items.append(AssetDetailItem(title: String(localized: "asset_detail.field.notes"), value: notes))
        }

        items.append(
            AssetDetailItem(
                title: String(localized: "asset_detail.field.created"),
                value: createdAt.formatted(date: .abbreviated, time: .omitted)
            )
        )

        return items
    }
}

private struct AssetTaskCard: View {
    let task: MaintenanceTask

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(task.repeatSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    NavigationStack {
        AssetDetailView(asset: PreviewSampleData.assets[0])
    }
}
