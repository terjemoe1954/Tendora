//
//  AttachmentPreviewView.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import QuickLook
import SwiftUI

struct AttachmentPreviewItem: Identifiable {
    let url: URL

    var id: URL {
        url
    }
}

struct AttachmentPreviewView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    let fileURL: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(fileURL: fileURL) {
            dismiss()
        }
    }

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.view.addGestureRecognizer(context.coordinator.dismissTapGestureRecognizer)
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        context.coordinator.fileURL = fileURL
        uiViewController.reloadData()
    }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        var fileURL: URL
        let onDismiss: () -> Void
        let dismissTapGestureRecognizer: UITapGestureRecognizer

        init(fileURL: URL, onDismiss: @escaping () -> Void) {
            self.fileURL = fileURL
            self.onDismiss = onDismiss
            dismissTapGestureRecognizer = UITapGestureRecognizer()
            super.init()
            dismissTapGestureRecognizer.addTarget(self, action: #selector(handlePreviewTap))
            dismissTapGestureRecognizer.cancelsTouchesInView = false
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            fileURL as NSURL
        }

        @objc
        private func handlePreviewTap() {
            onDismiss()
        }
    }
}
