//
//  AttachmentRowView.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import SwiftUI

struct AttachmentRowView: View {
    let attachment: Attachment
    let onOpen: (() -> Void)?
    let onShare: (() -> Void)?
    let onDelete: (() -> Void)?

    init(
        attachment: Attachment,
        onOpen: (() -> Void)? = nil,
        onShare: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.attachment = attachment
        self.onOpen = onOpen
        self.onShare = onShare
        self.onDelete = onDelete
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: attachment.type.symbolName)
                .font(.headline)
                .foregroundStyle(.blue)
                .frame(width: 34, height: 34)
                .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(attachment.displayName)
                    .font(.headline)
                    .lineLimit(1)

                Text(attachment.type.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(attachment.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    if let onShare {
                        Button(action: onShare) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("attachment.share.action")
                    }

                    if let onDelete {
                        Button(role: .destructive, action: onDelete) {
                            Image(systemName: "trash")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("attachment.delete.action")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onOpen?()
        }
    }
}
