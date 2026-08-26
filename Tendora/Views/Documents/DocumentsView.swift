//
//  DocumentsView.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import SwiftData
import SwiftUI

struct DocumentsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Attachment.createdAt, order: .reverse) private var attachments: [Attachment]
    @State private var attachmentPendingDeletion: Attachment?
    @State private var previewItem: AttachmentPreviewItem?
    @State private var shareItem: AttachmentShareItem?
    @State private var alertState: AppAlertState?

    var body: some View {
        NavigationStack {
            Group {
                if attachments.isEmpty {
                    ContentUnavailableView(
                        "documents.empty.title",
                        systemImage: "doc.text",
                        description: Text("documents.empty.message")
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(groupedAttachments, id: \.asset.id) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(group.asset.name)
                                        .font(.headline)

                                    ForEach(group.items) { attachment in
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("tab.documents")
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
    }

    private var groupedAttachments: [(asset: Asset, items: [Attachment])] {
        let grouped = Dictionary(grouping: attachments) { attachment in
            attachment.asset
        }

        return grouped
            .compactMap { asset, items in
                guard let asset else { return nil }
                return (asset: asset, items: items.sorted { $0.createdAt > $1.createdAt })
            }
            .sorted { $0.asset.name.localizedCaseInsensitiveCompare($1.asset.name) == .orderedAscending }
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

#Preview {
    DocumentsView()
        .modelContainer(PreviewSampleData.container)
}
