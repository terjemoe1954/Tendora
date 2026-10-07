//
//  UserManualView.swift
//  Tendora
//
//  Created by Codex on 07/10/2026.
//

import SwiftUI

struct UserManualView: View {
    var body: some View {
        List {
            Section {
                UserManualInfoRow(
                    systemImage: "house.fill",
                    titleKey: "user_manual.home.title",
                    messageKey: "user_manual.home.message"
                )

                UserManualInfoRow(
                    systemImage: "checklist",
                    titleKey: "user_manual.tasks.title",
                    messageKey: "user_manual.tasks.message"
                )

                UserManualInfoRow(
                    systemImage: "paperclip",
                    titleKey: "user_manual.documents.title",
                    messageKey: "user_manual.documents.message"
                )
            } header: {
                Text("user_manual.section.daily_use")
            }

            Section {
                UserManualInfoRow(
                    systemImage: "chart.bar.doc.horizontal",
                    titleKey: "user_manual.reports.title",
                    messageKey: "user_manual.reports.message"
                )

                UserManualInfoRow(
                    systemImage: "square.and.arrow.up",
                    titleKey: "user_manual.report_pdf.title",
                    messageKey: "user_manual.report_pdf.message"
                )
            } header: {
                Text("user_manual.section.reports")
            }

            Section {
                UserManualInfoRow(
                    systemImage: "icloud.fill",
                    titleKey: "user_manual.sync.title",
                    messageKey: "user_manual.sync.message"
                )

                UserManualInfoRow(
                    systemImage: "externaldrive.badge.timemachine",
                    titleKey: "user_manual.backup.title",
                    messageKey: "user_manual.backup.message"
                )

                UserManualInfoRow(
                    systemImage: "trash",
                    titleKey: "user_manual.reset.title",
                    messageKey: "user_manual.reset.message"
                )
            } header: {
                Text("user_manual.section.data")
            }

            Section {
                UserManualInfoRow(
                    systemImage: "star",
                    titleKey: "user_manual.premium.title",
                    messageKey: "user_manual.premium.message"
                )

                UserManualInfoRow(
                    systemImage: "bell.badge",
                    titleKey: "user_manual.notifications.title",
                    messageKey: "user_manual.notifications.message"
                )
            } header: {
                Text("user_manual.section.settings")
            }
        }
        .navigationTitle("user_manual.title")
    }
}

private struct UserManualInfoRow: View {
    let systemImage: String
    let titleKey: LocalizedStringKey
    let messageKey: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 5) {
                Text(titleKey)
                    .font(.headline)

                Text(messageKey)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
