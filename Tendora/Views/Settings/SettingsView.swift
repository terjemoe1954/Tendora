//
//  SettingsView.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @AppStorage("defaultReminderOffset") private var defaultReminderOffsetRawValue = ReminderOffset.oneWeekBefore.rawValue
    @AppStorage("appAppearance") private var appAppearanceRawValue = AppAppearance.system.rawValue
    @AppStorage("appLanguage") private var appLanguageRawValue = AppLanguage.system.rawValue
    @State private var cloudSyncStatus = CloudSyncStatusService()
    @State private var premiumEntitlement = PremiumEntitlementService()
    @State private var isPresentingAbout = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(cloudSyncStatus.status.title, systemImage: syncStatusIconName)
                            .font(.headline)

                        Text(cloudSyncStatus.status.message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)

                    Button {
                        Task {
                            await cloudSyncStatus.refresh()
                        }
                    } label: {
                        Label("settings.sync.refresh", systemImage: "arrow.clockwise")
                    }
                } header: {
                    Text("settings.section.sync")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text(LocalizedStringKey(premiumEntitlement.status.titleLocalizationKey))
                        } icon: {
                            Image(systemName: premiumStatusIconName)
                        }
                        .font(.headline)

                        Text(LocalizedStringKey(premiumEntitlement.status.messageLocalizationKey))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)

                    PremiumFeatureRow(titleKey: "settings.premium.feature.icloud", systemImage: "icloud")
                    PremiumFeatureRow(titleKey: "settings.premium.feature.backup", systemImage: "externaldrive.badge.icloud")
                    PremiumFeatureRow(titleKey: "settings.premium.feature.attachments", systemImage: "paperclip")

                    Button {
                    } label: {
                        Label("settings.premium.upgrade", systemImage: "crown")
                    }
                    .disabled(true)
                } header: {
                    Text("settings.section.premium")
                } footer: {
                    Text("settings.premium.footer")
                }

                Section {
                    Button(action: openNotificationSettings) {
                        Label("settings.notifications", systemImage: "bell.badge")
                    }

                    Picker("settings.default_reminder", selection: $defaultReminderOffsetRawValue) {
                        ForEach(ReminderOffset.allCases) { offset in
                            Text(offset.displayName).tag(offset.rawValue)
                        }
                    }
                } header: {
                    Text("settings.section.reminders")
                } footer: {
                    Text("settings.notifications.help")
                }

                Section("settings.section.appearance") {
                    Picker("settings.appearance", selection: $appAppearanceRawValue) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.displayName).tag(appearance.rawValue)
                        }
                    }

                    Picker("settings.language", selection: $appLanguageRawValue) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language.rawValue)
                        }
                    }
                }

                Section("settings.section.support") {
                    Button {
                        isPresentingAbout = true
                    } label: {
                        Label("settings.about", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("tab.settings")
            .sheet(isPresented: $isPresentingAbout) {
                AboutTendoraView()
            }
            .task {
                await cloudSyncStatus.refresh()
            }
        }
    }

    private var syncStatusIconName: String {
        switch cloudSyncStatus.status {
        case .checking:
            return "icloud"
        case .available:
            return "icloud.fill"
        case .noAccount, .restricted, .temporarilyUnavailable, .unavailable:
            return "icloud.slash"
        }
    }

    private var premiumStatusIconName: String {
        premiumEntitlement.isPremiumUnlocked ? "crown.fill" : "crown"
    }

    private func openNotificationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        openURL(settingsURL)
    }
}

private struct PremiumFeatureRow: View {
    let titleKey: String
    let systemImage: String

    var body: some View {
        Label {
            Text(LocalizedStringKey(titleKey))
        } icon: {
            Image(systemName: systemImage)
        }
    }
}

private struct AboutTendoraView: View {
    @Environment(\.dismiss) private var dismiss

    private var versionString: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var buildString: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "checklist.checked")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(.blue)

                        Text("app.name")
                            .font(.title2.weight(.semibold))

                        Text("settings.about.message")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .listRowBackground(Color.clear)
                }

                Section("settings.about.section.app") {
                    LabeledContent("settings.about.version", value: versionString)
                    LabeledContent("settings.about.build", value: buildString)
                }
            }
            .navigationTitle("settings.about")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("common.done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
