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

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: context.coordinator,
            action: #selector(Coordinator.closePreview)
        )
        controller.view.addGestureRecognizer(context.coordinator.dismissDoubleTapGestureRecognizer)

        return UINavigationController(rootViewController: controller)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        context.coordinator.fileURL = fileURL
        guard let previewController = uiViewController.topViewController as? QLPreviewController else {
            return
        }

        previewController.reloadData()
    }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        var fileURL: URL
        let onDismiss: () -> Void
        let dismissDoubleTapGestureRecognizer: UITapGestureRecognizer

        init(fileURL: URL, onDismiss: @escaping () -> Void) {
            self.fileURL = fileURL
            self.onDismiss = onDismiss
            dismissDoubleTapGestureRecognizer = UITapGestureRecognizer()
            super.init()
            dismissDoubleTapGestureRecognizer.addTarget(self, action: #selector(closePreview))
            dismissDoubleTapGestureRecognizer.numberOfTapsRequired = 2
            dismissDoubleTapGestureRecognizer.cancelsTouchesInView = false
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            fileURL as NSURL
        }

        @objc
        func closePreview() {
            onDismiss()
        }
    }
}
