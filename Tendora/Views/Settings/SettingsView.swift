//
//  SettingsView.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(PremiumEntitlementService.self) private var premiumEntitlementService
    @Environment(\.openURL) private var openURL
    @AppStorage("defaultReminderOffset") private var defaultReminderOffsetRawValue = ReminderOffset.oneWeekBefore.rawValue
    @AppStorage("appAppearance") private var appAppearanceRawValue = AppAppearance.system.rawValue
    @AppStorage("appLanguage") private var appLanguageRawValue = AppLanguage.system.rawValue
    @State private var cloudSyncStatus = CloudSyncStatusService()
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

    private func openNotificationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        openURL(settingsURL)
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
