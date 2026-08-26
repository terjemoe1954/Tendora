//
//  TaskDetailView.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import SwiftData
import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let task: MaintenanceTask
    @State private var isUpdatingTask = false
    @State private var isPresentingAddAttachment = false
    @State private var isPresentingEditTask = false
    @State private var isShowingDeleteTaskConfirmation = false
    @State private var attachmentPendingDeletion: Attachment?
    @State private var previewItem: AttachmentPreviewItem?
    @State private var shareItem: AttachmentShareItem?
    @State private var alertState: AppAlertState?
    @State private var completionConfirmationMessage: String?

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    summaryCard
                    detailsSection
                    attachmentsSection
                    historySection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground))

            if let completionConfirmationMessage {
                completionConfirmationBanner(message: completionConfirmationMessage)
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .navigationTitle(task.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        isPresentingAddAttachment = true
                    } label: {
                        Label("task_detail.add_attachment", systemImage: "paperclip")
                    }

                    Button {
                        isPresentingEditTask = true
                    } label: {
                        Label("task_detail.edit_task", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        isShowingDeleteTaskConfirmation = true
                    } label: {
                        Label("task_detail.delete_task", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isPresentingAddAttachment) {
            AddAttachmentView(asset: task.asset, task: task)
        }
        .sheet(isPresented: $isPresentingEditTask) {
            if let asset = task.asset {
                AddTaskView(asset: asset, taskToEdit: task)
            }
        }
        .confirmationDialog("task_detail.delete_task_confirmation", isPresented: $isShowingDeleteTaskConfirmation, titleVisibility: .visible) {
            Button("task_detail.delete_task", role: .destructive) {
                Task {
                    await deleteTask()
                }
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

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(task.title)
                .font(.title2.weight(.semibold))

            if let assetName = task.asset?.name {
                Label(assetName, systemImage: task.asset?.type.symbolName ?? "house")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("task_detail.due_date")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.headline)
                }

                Spacer()

                if task.isCompleted == false {
                    Button("task_detail.mark_done") {
                        Task {
                            await markTaskDone()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isUpdatingTask)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("task_detail.section.details")
                .font(.headline)

            VStack(spacing: 0) {
                DetailRow(title: String(localized: "task_detail.repeat_rule"), value: task.repeatSummary)
                Divider().padding(.leading, 16)
                DetailRow(title: String(localized: "task_detail.reminder"), value: task.reminderSummary)
                Divider().padding(.leading, 16)
                DetailRow(title: String(localized: "task_detail.status"), value: task.currentStatus)

                if let notes = task.notes, notes.isEmpty == false {
                    Divider().padding(.leading, 16)
                    DetailRow(title: String(localized: "task_detail.notes"), value: notes)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("task_detail.section.history")
                .font(.headline)

            if task.completionRecords.isEmpty {
                ContentUnavailableView(
                    "task_detail.history.empty_title",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("task_detail.history.empty_message")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sortedHistory.enumerated()), id: \.element.id) { index, record in
                        DetailRow(
                            title: record.completedAt.formatted(date: .abbreviated, time: .omitted),
                            value: record.notes ?? String(localized: "task_detail.history.completed")
                        )

                        if index < sortedHistory.count - 1 {
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

    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("task_detail.section.attachments")
                    .font(.headline)

                Spacer()

                Button("task_detail.add_attachment") {
                    isPresentingAddAttachment = true
                }
                .font(.subheadline.weight(.semibold))
            }

            if task.attachments.isEmpty {
                ContentUnavailableView(
                    "task_detail.attachments.empty_title",
                    systemImage: "paperclip",
                    description: Text("task_detail.attachments.empty_message")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(task.attachments.sorted { $0.createdAt > $1.createdAt }) { attachment in
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

    private var sortedHistory: [CompletionRecord] {
        task.completionRecords.sorted { $0.completedAt > $1.completedAt }
    }

    private func markTaskDone() async {
        isUpdatingTask = true
        let nextDueDate = task.nextDueDateAfterCompletion
        task.markCompleted()

        if task.isCompleted {
            await NotificationManager.shared.cancelNotification(for: task)
        } else {
            do {
                try await NotificationManager.shared.scheduleNotification(for: task)
            } catch {
                alertState = AppAlertState(
                    title: String(localized: "error.notifications.title"),
                    message: error.localizedDescription
                )
            }
        }

        isUpdatingTask = false
        await MainActor.run {
            showCompletionConfirmation(nextDueDate: nextDueDate)
        }
    }

    private func completionConfirmationBanner(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.green)
        )
        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
    }

    @MainActor
    private func showCompletionConfirmation(nextDueDate: Date?) {
        let message: String

        if let nextDueDate {
            let format = String(localized: "task_detail.completion_recorded_next_due")
            message = String(
                format: format,
                locale: .current,
                nextDueDate.formatted(date: .abbreviated, time: .omitted)
            )
        } else {
            message = String(localized: "task_detail.completion_recorded")
        }

        withAnimation {
            completionConfirmationMessage = message
        }

        Task {
            try? await Task.sleep(for: .seconds(2.5))

            await MainActor.run {
                guard completionConfirmationMessage == message else { return }

                withAnimation {
                    completionConfirmationMessage = nil
                }
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

    private func deleteTask() async {
        await NotificationManager.shared.cancelNotification(for: task)
        for attachment in task.attachments {
            try? AttachmentManager.shared.deleteAttachmentFile(for: attachment)
        }
        modelContext.delete(task)
        dismiss()
    }

    private func deleteAttachment(_ attachment: Attachment) {
        do {
            try AttachmentManager.shared.deleteAttachmentFile(for: attachment)
        } catch {
            alertState = AppAlertState(
                title: String(localized: "error.attachments.title"),
                message: String(localized: "error.attachments.delete_failed.message")
            )
        }
        modelContext.delete(attachment)
        attachmentPendingDeletion = nil
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

private struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        LabeledContent(title, value: value)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(task: PreviewSampleData.tasks[0])
    }
    .modelContainer(PreviewSampleData.container)
}
