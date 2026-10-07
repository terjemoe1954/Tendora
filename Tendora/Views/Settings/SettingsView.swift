//
//  SettingsView.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import StoreKit
import SwiftData
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(PremiumEntitlementService.self) private var premiumEntitlementService
    @Environment(\.openURL) private var openURL
    @AppStorage("defaultReminderOffset") private var defaultReminderOffsetRawValue = ReminderOffset.oneWeekBefore.rawValue
    @AppStorage("appAppearance") private var appAppearanceRawValue = AppAppearance.system.rawValue
    @AppStorage("appLanguage") private var appLanguageRawValue = AppLanguage.system.rawValue
    @State private var cloudSyncStatus = CloudSyncStatusService()
    @State private var isPresentingAbout = false

    let isResettingData: Bool
    let resetAllUserData: () async -> Void

    init(
        isResettingData: Bool = false,
        resetAllUserData: @escaping () async -> Void = {}
    ) {
        self.isResettingData = isResettingData
        self.resetAllUserData = resetAllUserData
    }

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

                BackupRestoreSettingsSection()

                PremiumSettingsSection(premiumEntitlementService: premiumEntitlementService)

                Section {
                    Button(action: openNotificationSettings) {
                        Label("settings.notifications", systemImage: "bell.badge")
                    }

                    Picker("settings.default_reminder", selection: $defaultReminderOffsetRawValue) {
                        ForEach(ReminderOffset.allCases) { offset in
                            Text(LocalizedStringKey(offset.displayNameLocalizationKey)).tag(offset.rawValue)
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

                HelpSettingsSection()

                Section("settings.section.support") {
                    Button {
                        isPresentingAbout = true
                    } label: {
                        Label("settings.about", systemImage: "info.circle")
                    }
                }

                DataResetSettingsSection(
                    isResetting: isResettingData,
                    resetAllUserData: resetAllUserData
                )
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

    private func openNotificationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        openURL(settingsURL)
    }
}

private struct HelpSettingsSection: View {
    var body: some View {
        Section("settings.section.help") {
            NavigationLink {
                UserManualView()
            } label: {
                Label("settings.user_manual", systemImage: "book")
            }

            NavigationLink {
                ReportsView()
            } label: {
                Label("settings.reports", systemImage: "chart.bar.doc.horizontal")
            }
        }
    }
}

private struct BackupRestoreSettingsSection: View {
    @Environment(\.modelContext) private var modelContext

    @State private var backupDocument = TendoraBackupDocument()
    @State private var isPresentingExporter = false
    @State private var isPresentingImporter = false
    @State private var restoreConfirmation: RestoreConfirmation?
    @State private var alertState: BackupAlertState?

    private let backupService = BackupRestoreService.shared

    var body: some View {
        Section {
            Button {
                createBackup()
            } label: {
                Label("settings.backup.export", systemImage: "square.and.arrow.up")
            }

            Button(role: .destructive) {
                isPresentingImporter = true
            } label: {
                Label("settings.backup.restore", systemImage: "arrow.clockwise.icloud")
            }
        } header: {
            Text("settings.section.backup")
        } footer: {
            Text("settings.backup.footer")
        }
        .fileExporter(
            isPresented: $isPresentingExporter,
            document: backupDocument,
            contentType: .tendoraBackup,
            defaultFilename: defaultBackupFilename
        ) { result in
            switch result {
            case .success:
                alertState = BackupAlertState(
                    title: "settings.backup.export.success.title",
                    message: "settings.backup.export.success.message"
                )
            case .failure(let error):
                showError(error)
            }
        }
        .fileImporter(
            isPresented: $isPresentingImporter,
            allowedContentTypes: TendoraBackupDocument.readableContentTypes
        ) { result in
            handleImport(result)
        }
        .confirmationDialog(
            "settings.backup.restore.confirm.title",
            item: $restoreConfirmation,
            titleVisibility: .visible
        ) { confirmation in
            Button("settings.backup.restore.confirm.action", role: .destructive) {
                Task {
                    await restore(confirmation.archive)
                }
            }

            Button("common.cancel", role: .cancel) {}
        } message: { confirmation in
            Text(restoreConfirmationMessage(for: confirmation.archive.summary))
        }
        .alert(item: $alertState) { alertState in
            Alert(
                title: Text(LocalizedStringKey(alertState.title)),
                message: Text(alertState.message),
                dismissButton: .default(Text("common.ok"))
            )
        }
    }

    private var defaultBackupFilename: String {
        let date = Date.now.formatted(.iso8601.year().month().day())
        return "Tendora-Backup-\(date).\(BackupRestoreService.backupFileExtension)"
    }

    private func createBackup() {
        do {
            let data = try backupService.encodedArchive(from: modelContext)
            backupDocument = TendoraBackupDocument(data: data)
            isPresentingExporter = true
        } catch {
            showError(error)
        }
    }

    private func handleImport(_ result: Result<URL, Error>) {
        do {
            let url = try result.get()
            let didAccessSecurityScope = url.startAccessingSecurityScopedResource()
            defer {
                if didAccessSecurityScope {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let data = try Data(contentsOf: url)
            let archive = try backupService.archive(from: data)
            restoreConfirmation = RestoreConfirmation(archive: archive)
        } catch {
            showError(error)
        }
    }

    private func restore(_ archive: TendoraBackupArchive) async {
        do {
            let summary = try backupService.restore(archive, into: modelContext)
            let restoredTasks = try modelContext.fetch(FetchDescriptor<MaintenanceTask>())
            try await NotificationManager.shared.rescheduleNotifications(for: restoredTasks)
            let message = String(
                localized: "settings.backup.restore.success.message \(summary.assetCount) \(summary.taskCount) \(summary.attachmentCount)"
            )
            alertState = BackupAlertState(
                title: "settings.backup.restore.success.title",
                message: message
            )
        } catch {
            showError(error)
        }
    }

    private func restoreConfirmationMessage(for summary: BackupArchiveSummary) -> String {
        String(
            localized: "settings.backup.restore.confirm.message \(summary.assetCount) \(summary.taskCount) \(summary.attachmentCount)"
        )
    }

    private func showError(_ error: Error) {
        alertState = BackupAlertState(
            title: "settings.backup.error.title",
            message: error.localizedDescription
        )
    }
}

private struct RestoreConfirmation: Identifiable {
    let id = UUID()
    let archive: TendoraBackupArchive
}

private struct BackupAlertState: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

private struct DataResetSettingsSection: View {
    @State private var isPresentingResetConfirmation = false

    let isResetting: Bool
    let resetAllUserData: () async -> Void

    var body: some View {
        Section {
            Button(role: .destructive) {
                isPresentingResetConfirmation = true
            } label: {
                if isResetting {
                    Label("settings.reset.in_progress", systemImage: "hourglass")
                } else {
                    Label("settings.reset.action", systemImage: "trash")
                }
            }
            .disabled(isResetting)
        } header: {
            Text("settings.section.reset")
        } footer: {
            Text("settings.reset.footer")
        }
        .confirmationDialog(
            "settings.reset.confirm.title",
            isPresented: $isPresentingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("settings.reset.confirm.action", role: .destructive) {
                Task {
                    await resetAllUserData()
                }
            }

            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("settings.reset.confirm.message")
        }
    }
}

private struct PremiumSettingsSection: View {
    let premiumEntitlementService: PremiumEntitlementService

    @State private var alertState: AppAlertState?
    @State private var isPresentingManageSubscriptions = false

    var body: some View {
        Section {
            PremiumStatusRow(
                status: premiumEntitlementService.status,
                expirationDate: premiumEntitlementService.activePremiumExpirationDate
            )

            if premiumEntitlementService.hasEarlySupporterAttachmentAccess, premiumEntitlementService.isPremiumUnlocked == false {
                Label("settings.premium.early_supporter", systemImage: "checkmark.seal")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if premiumEntitlementService.isPremiumUnlocked == false {
                if premiumEntitlementService.isLoadingProducts {
                    Label("settings.premium.loading", systemImage: "hourglass")
                        .foregroundStyle(.secondary)
                } else if premiumEntitlementService.products.isEmpty {
                    Label("settings.premium.error.products_unavailable", systemImage: "exclamationmark.triangle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        Task {
                            await premiumEntitlementService.loadProducts()
                            updateAlertIfNeeded()
                        }
                    } label: {
                        Label("settings.premium.retry_products", systemImage: "arrow.clockwise")
                    }
                } else {
                    ForEach(premiumEntitlementService.products, id: \.id) { product in
                        PremiumProductButton(
                            product: product,
                            isPurchasing: premiumEntitlementService.purchaseState == .purchasing(productID: product.id),
                            isDisabled: premiumEntitlementService.isStoreBusy || premiumEntitlementService.canOfferPurchases == false
                        ) {
                            Task {
                                await premiumEntitlementService.purchase(product)
                                updateAlertIfNeeded()
                            }
                        }
                    }
                }
            }

            Button {
                Task {
                    await premiumEntitlementService.restorePurchases()
                    updateAlertIfNeeded()
                }
            } label: {
                Label("settings.premium.restore", systemImage: "arrow.clockwise.circle")
            }
            .disabled(premiumEntitlementService.isStoreBusy || premiumEntitlementService.hasPendingPurchase)

            if premiumEntitlementService.isPremiumUnlocked, canShowManageSubscriptions {
                Button {
                    isPresentingManageSubscriptions = true
                } label: {
                    Label("settings.premium.manage_subscription", systemImage: "person.crop.circle.badge.checkmark")
                }
            }

            if premiumEntitlementService.canMakePayments == false,
               premiumEntitlementService.isPremiumUnlocked == false {
                Label("settings.premium.payments_unavailable", systemImage: "cart.badge.minus")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if premiumEntitlementService.purchaseState == .pending {
                Label("settings.premium.pending", systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            PremiumFeatureList()
        } header: {
            Text("settings.section.premium")
        } footer: {
            VStack(alignment: .leading, spacing: 6) {
                Text("settings.premium.footer")
                PremiumSubscriptionDisclosureView()
            }
        }
        .alert(item: $alertState) { alertState in
            Alert(
                title: Text(LocalizedStringKey(alertState.title)),
                message: Text(LocalizedStringKey(alertState.message)),
                dismissButton: .default(Text("common.ok")) {
                    premiumEntitlementService.clearStoreError()
                }
            )
        }
        .manageSubscriptionsSheet(isPresented: $isPresentingManageSubscriptions)
        .task {
            premiumEntitlementService.refreshPaymentAvailability()
        }
        .onChange(of: isPresentingManageSubscriptions) { _, isPresented in
            guard isPresented == false else {
                return
            }

            Task {
                await premiumEntitlementService.refreshEntitlements()
            }
        }
    }

    private var canShowManageSubscriptions: Bool {
        #if targetEnvironment(macCatalyst)
        return false
        #else
        return ProcessInfo.processInfo.isiOSAppOnMac == false
        #endif
    }

    private func updateAlertIfNeeded() {
        guard let storeError = premiumEntitlementService.storeError else {
            return
        }

        alertState = AppAlertState(
            title: storeError.titleLocalizationKey,
            message: storeError.messageLocalizationKey
        )
    }
}

private struct PremiumStatusRow: View {
    let status: PremiumEntitlementStatus
    let expirationDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(LocalizedStringKey(status.titleLocalizationKey), systemImage: iconName)
                .font(.headline)

            Text(LocalizedStringKey(status.messageLocalizationKey))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if status == .active, let expirationDate {
                Text("settings.premium.current_period_ends \(expirationDate, format: .dateTime.day().month().year())")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch status {
        case .active:
            return "checkmark.seal.fill"
        case .notPurchased:
            return "star"
        }
    }
}

private struct PremiumProductButton: View {
    let product: Product
    let isPurchasing: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.body)

                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 12)

                if isPurchasing {
                    ProgressView()
                } else {
                    Text(product.displayPrice)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.blue)
                }
            }
            .contentShape(Rectangle())
        }
        .disabled(isDisabled)
    }
}

private struct PremiumFeatureList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("settings.premium.feature.attachments", systemImage: "paperclip")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .padding(.vertical, 4)
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
        .environment(PremiumEntitlementService())
}
