//
//  AddAttachmentView.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import PhotosUI
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct AddAttachmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let asset: Asset?
    let task: MaintenanceTask?

    @State private var attachmentType: AttachmentType = .other
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isPresentingFileImporter = false
    @State private var isImporting = false
    @State private var alertState: AppAlertState?

    var body: some View {
        NavigationStack {
            Form {
                Section("add_attachment.section.linked_to") {
                    if let task {
                        LabeledContent(String(localized: "add_attachment.field.task"), value: task.title)
                    }

                    if let asset {
                        LabeledContent(String(localized: "add_attachment.field.asset"), value: asset.name)
                    }
                }

                Section("add_attachment.section.type") {
                    Picker("add_attachment.field.type", selection: $attachmentType) {
                        ForEach(AttachmentType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section("add_attachment.section.import") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("add_attachment.photo", systemImage: "photo.on.rectangle")
                    }

                    Button {
                        isPresentingFileImporter = true
                    } label: {
                        Label("add_attachment.document", systemImage: "doc.badge.plus")
                    }
                }

                Section {
                    Text("add_attachment.help")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("add_attachment.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("common.cancel") {
                        dismiss()
                    }
                }
            }
            .disabled(isImporting)
            .fileImporter(
                isPresented: $isPresentingFileImporter,
                allowedContentTypes: [.item],
                onCompletion: handleImportedFile
            )
            .task(id: selectedPhoto) {
                guard let selectedPhoto else { return }
                await importPhoto(from: selectedPhoto)
            }
            .alert(item: $alertState) { alert in
                Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text(String(localized: "common.ok"))))
            }
        }
    }

    private func handleImportedFile(_ result: Result<URL, Error>) {
        guard case let .success(url) = result else {
            alertState = AppAlertState(
                title: String(localized: "error.attachments.title"),
                message: String(localized: "error.attachments.import_failed.message")
            )
            return
        }

        isImporting = true
        defer { isImporting = false }

        do {
            let attachment = try AttachmentManager.shared.createFileAttachment(
                from: url,
                type: attachmentType,
                asset: asset ?? task?.asset,
                task: task
            )
            modelContext.insert(attachment)
            try modelContext.save()
            dismiss()
        } catch {
            alertState = AppAlertState(
                title: String(localized: "error.data.title"),
                message: String(localized: "error.data.save_failed.message")
            )
        }
    }

    private func importPhoto(from item: PhotosPickerItem) async {
        isImporting = true
        defer {
            isImporting = false
            selectedPhoto = nil
        }

        guard let data = try? await item.loadTransferable(type: Data.self) else {
            alertState = AppAlertState(
                title: String(localized: "error.attachments.title"),
                message: String(localized: "error.attachments.photo_failed.message")
            )
            return
        }

        do {
            let attachment = try AttachmentManager.shared.createPhotoAttachment(
                data: data,
                displayName: String(localized: "add_attachment.default_photo_name"),
                asset: asset ?? task?.asset,
                task: task
            )
            modelContext.insert(attachment)
            try modelContext.save()
            dismiss()
        } catch {
            alertState = AppAlertState(
                title: String(localized: "error.data.title"),
                message: String(localized: "error.data.save_failed.message")
            )
        }
    }
}

#Preview {
    AddAttachmentView(asset: PreviewSampleData.assets[0], task: nil)
        .modelContainer(PreviewSampleData.container)
}
