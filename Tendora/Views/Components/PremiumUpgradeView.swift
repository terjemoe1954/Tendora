//
//  PremiumUpgradeView.swift
//  Tendora
//
//  Created by Codex on 26/09/2026.
//

import StoreKit
import SwiftUI

struct PremiumUpgradeView: View {
    @Environment(PremiumEntitlementService.self) private var premiumEntitlementService
    @Environment(\.dismiss) private var dismiss

    let titleKey: String
    let messageKey: String

    @State private var alertState: AppAlertState?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    PremiumUpgradeHeader(titleKey: titleKey, messageKey: messageKey)
                        .listRowBackground(Color.clear)
                }

                Section {
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
                            PremiumUpgradeProductRow(
                                product: product,
                                isPurchasing: premiumEntitlementService.purchaseState == .purchasing(productID: product.id),
                                isDisabled: premiumEntitlementService.isStoreBusy || premiumEntitlementService.canOfferPurchases == false
                            ) {
                                Task {
                                    await premiumEntitlementService.purchase(product)
                                    if premiumEntitlementService.isPremiumUnlocked {
                                        dismiss()
                                    } else {
                                        updateAlertIfNeeded()
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        Task {
                            await premiumEntitlementService.restorePurchases()
                            if premiumEntitlementService.isPremiumUnlocked {
                                dismiss()
                            } else {
                                updateAlertIfNeeded()
                            }
                        }
                    } label: {
                        Label("settings.premium.restore", systemImage: "arrow.clockwise.circle")
                    }
                    .disabled(premiumEntitlementService.isStoreBusy || premiumEntitlementService.hasPendingPurchase)

                    if premiumEntitlementService.canMakePayments == false {
                        Label("settings.premium.payments_unavailable", systemImage: "cart.badge.minus")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if premiumEntitlementService.purchaseState == .pending {
                        Label("settings.premium.pending", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("premium.upgrade.footer")
                        PremiumSubscriptionDisclosureView()
                    }
                }
            }
            .navigationTitle("settings.section.premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("common.done") {
                        dismiss()
                    }
                }
            }
            .task {
                premiumEntitlementService.refreshPaymentAvailability()
                dismissIfPremiumIsActive()
            }
            .onChange(of: premiumEntitlementService.isPremiumUnlocked) { _, isUnlocked in
                if isUnlocked {
                    dismissIfPremiumIsActive()
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
        }
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

    private func dismissIfPremiumIsActive() {
        if premiumEntitlementService.isPremiumUnlocked {
            dismiss()
        }
    }
}

private struct PremiumUpgradeHeader: View {
    let titleKey: String
    let messageKey: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.blue)

            Text(LocalizedStringKey(titleKey))
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(LocalizedStringKey(messageKey))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

private struct PremiumUpgradeProductRow: View {
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

#Preview {
    PremiumUpgradeView(
        titleKey: "premium.upgrade.attachments.title",
        messageKey: "premium.upgrade.attachments.message"
    )
    .environment(PremiumEntitlementService())
}
