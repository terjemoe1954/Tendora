//
//  AttachmentShareSheetView.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import SwiftUI
import UIKit

struct AttachmentShareItem: Identifiable {
    let url: URL

    var id: URL {
        url
    }
}

struct AttachmentShareSheetView: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
