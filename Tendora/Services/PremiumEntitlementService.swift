//
//  PremiumEntitlementService.swift
//  Tendora
//
//  Created by Codex on 05/09/2026.
//

import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class PremiumEntitlementService {
    static let monthlyProductID = "tendora_premium_monthly"
    static let yearlyProductID = "tendora_premium_yearly"

    private static let premiumProductIDs: Set<String> = [
        monthlyProductID,
        yearlyProductID
    ]
    private static let paidAttachmentGateBuildNumber = 5

    private let userDefaults: UserDefaults
    private let premiumUnlockedKey = "premiumEntitlementUnlocked"
    private let earlySupporterAttachmentAccessKey = "premiumEarlySupporterAttachmentAccess"

    @ObservationIgnored
    private var transactionUpdatesTask: Task<Void, Never>?

    private(set) var products: [Product] = []
    private(set) var isLoadingProducts = false
    private(set) var isPremiumUnlocked: Bool
    private(set) var activePremiumExpirationDate: Date?
    private(set) var hasEarlySupporterAttachmentAccess: Bool
    private(set) var canMakePayments = AppStore.canMakePayments
    private(set) var purchaseState: PremiumPurchaseState = .idle
    private(set) var storeError: PremiumStoreError?

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        Self.initializeEarlySupporterAttachmentAccessIfNeeded(userDefaults: userDefaults)
        isPremiumUnlocked = userDefaults.bool(forKey: premiumUnlockedKey)
        hasEarlySupporterAttachmentAccess = userDefaults.bool(forKey: earlySupporterAttachmentAccessKey)
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    var status: PremiumEntitlementStatus {
        isPremiumUnlocked ? .active : .notPurchased
    }

    var isStoreBusy: Bool {
        isLoadingProducts || purchaseState.isBusy
    }

    var hasPendingPurchase: Bool {
        purchaseState == .pending
    }

    var canOfferPurchases: Bool {
        canMakePayments && hasPendingPurchase == false && isPremiumUnlocked == false
    }

    var canCreateAttachments: Bool {
        isPremiumUnlocked || hasEarlySupporterAttachmentAccess
    }

    func start() async {
        refreshPaymentAvailability()
        observeTransactionUpdates()
        await refreshBusinessModelEntitlements()
        await refreshEntitlements()
        await loadProducts()
    }

    func loadProducts() async {
        guard isLoadingProducts == false else {
            return
        }

        isLoadingProducts = true
        storeError = nil
        defer { isLoadingProducts = false }

        do {
            let loadedProducts = try await Product.products(for: Self.premiumProductIDs)
            let loadedProductIDs = Set(loadedProducts.map(\.id))
            guard Self.premiumProductIDs.isSubset(of: loadedProductIDs) else {
                products = []
                storeError = .productsUnavailable
                return
            }

            products = loadedProducts.sorted { lhs, rhs in
                let lhsSortOrder = productSortOrder(for: lhs.id)
                let rhsSortOrder = productSortOrder(for: rhs.id)

                if lhsSortOrder == rhsSortOrder {
                    return lhs.id < rhs.id
                }

                return lhsSortOrder < rhsSortOrder
            }
            storeError = nil
        } catch {
            products = []
            storeError = .productsUnavailable
        }
    }

    func purchase(_ product: Product) async {
        refreshPaymentAvailability()
        guard canMakePayments, purchaseState.isBusy == false else {
            return
        }

        purchaseState = .purchasing(productID: product.id)
        storeError = nil
        defer {
            if purchaseState.isBusy {
                purchaseState = .idle
            }
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                await transaction.finish()
                await refreshEntitlements()
                storeError = nil
                purchaseState = .idle
            case .userCancelled:
                storeError = nil
                purchaseState = .idle
            case .pending:
                purchaseState = .pending
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            storeError = .purchaseFailed
        }
    }

    func restorePurchases() async {
        guard purchaseState.isBusy == false else {
            return
        }

        purchaseState = .restoring
        storeError = nil
        defer {
            if purchaseState.isBusy {
                purchaseState = .idle
            }
        }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            storeError = isPremiumUnlocked ? nil : .noActiveSubscription
            purchaseState = .idle
        } catch {
            storeError = .restoreFailed
        }
    }

    func clearStoreError() {
        storeError = nil
    }

    func refreshPaymentAvailability() {
        canMakePayments = AppStore.canMakePayments
    }

    private func observeTransactionUpdates() {
        guard transactionUpdatesTask == nil else {
            return
        }

        transactionUpdatesTask = Task { [weak self] in
            for await verificationResult in Transaction.updates {
                guard let self else {
                    return
                }

                do {
                    let transaction = try self.checkVerified(verificationResult)
                    await transaction.finish()
                    await self.refreshEntitlements()
                } catch {
                    self.storeError = .verificationFailed
                }
            }
        }
    }

    func refreshEntitlements() async {
        var hasActivePremium = false
        var latestExpirationDate: Date?

        for await verificationResult in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(verificationResult)
                if isActivePremiumTransaction(transaction) {
                    hasActivePremium = true
                    if let expirationDate = transaction.expirationDate,
                       latestExpirationDate.map({ expirationDate > $0 }) ?? true {
                        latestExpirationDate = expirationDate
                    }
                }
            } catch {
                storeError = .verificationFailed
            }
        }

        activePremiumExpirationDate = hasActivePremium ? latestExpirationDate : nil
        setPremiumUnlocked(hasActivePremium)

        if hasActivePremium, purchaseState == .pending {
            purchaseState = .idle
        }
    }

    private func refreshBusinessModelEntitlements() async {
        do {
            let verificationResult = try await AppTransaction.shared
            let appTransaction = try checkVerified(verificationResult)
            guard appTransaction.environment == .production else {
                return
            }

            if let originalBuildNumber = buildNumber(from: appTransaction.originalAppVersion),
               originalBuildNumber < Self.paidAttachmentGateBuildNumber {
                setEarlySupporterAttachmentAccess(true)
            }
        } catch {
            // Keep the local compatibility decision if the app transaction is unavailable.
        }
    }

    private func isActivePremiumTransaction(_ transaction: Transaction) -> Bool {
        guard Self.premiumProductIDs.contains(transaction.productID), transaction.revocationDate == nil else {
            return false
        }

        guard let expirationDate = transaction.expirationDate else {
            return false
        }

        return expirationDate > Date()
    }

    private func setPremiumUnlocked(_ isUnlocked: Bool) {
        guard isPremiumUnlocked != isUnlocked else {
            return
        }

        isPremiumUnlocked = isUnlocked
        userDefaults.set(isUnlocked, forKey: premiumUnlockedKey)
    }

    private func setEarlySupporterAttachmentAccess(_ hasAccess: Bool) {
        guard hasEarlySupporterAttachmentAccess != hasAccess else {
            return
        }

        hasEarlySupporterAttachmentAccess = hasAccess
        userDefaults.set(hasAccess, forKey: earlySupporterAttachmentAccessKey)
    }

    private func buildNumber(from originalAppVersion: String) -> Int? {
        let firstComponent = originalAppVersion.split(separator: ".").first ?? Substring(originalAppVersion)
        return Int(firstComponent)
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let signedType):
            return signedType
        case .unverified:
            throw PremiumStoreVerificationError()
        }
    }

    private func productSortOrder(for productID: String) -> Int {
        switch productID {
        case Self.monthlyProductID:
            return 0
        case Self.yearlyProductID:
            return 1
        default:
            return 2
        }
    }

    private static func initializeEarlySupporterAttachmentAccessIfNeeded(userDefaults: UserDefaults) {
        let initializedKey = "premiumEarlySupporterAttachmentAccessInitialized"
        guard userDefaults.bool(forKey: initializedKey) == false else {
            return
        }

        let hasUsedTendoraBeforePaidUpdate = userDefaults.bool(forKey: "hasSeenOnboarding")
        userDefaults.set(hasUsedTendoraBeforePaidUpdate, forKey: "premiumEarlySupporterAttachmentAccess")
        userDefaults.set(true, forKey: initializedKey)
    }
}

enum PremiumPurchaseState: Equatable {
    case idle
    case purchasing(productID: String)
    case pending
    case restoring

    var isBusy: Bool {
        switch self {
        case .idle, .pending:
            return false
        case .purchasing, .restoring:
            return true
        }
    }
}

enum PremiumStoreError: Equatable {
    case productsUnavailable
    case purchaseFailed
    case restoreFailed
    case noActiveSubscription
    case verificationFailed

    var titleLocalizationKey: String {
        switch self {
        case .noActiveSubscription:
            return "settings.premium.restore.no_active_title"
        case .productsUnavailable, .purchaseFailed, .restoreFailed, .verificationFailed:
            return "settings.premium.error.title"
        }
    }

    var messageLocalizationKey: String {
        switch self {
        case .productsUnavailable:
            return "settings.premium.error.products_unavailable"
        case .purchaseFailed:
            return "settings.premium.error.purchase_failed"
        case .restoreFailed:
            return "settings.premium.error.restore_failed"
        case .noActiveSubscription:
            return "settings.premium.restore.no_active_message"
        case .verificationFailed:
            return "settings.premium.error.verification_failed"
        }
    }
}

private struct PremiumStoreVerificationError: Error {}

enum PremiumEntitlementStatus: Equatable {
    case active
    case notPurchased

    var titleLocalizationKey: String {
        switch self {
        case .active:
            return "settings.premium.status.active"
        case .notPurchased:
            return "settings.premium.status.not_purchased"
        }
    }

    var messageLocalizationKey: String {
        switch self {
        case .active:
            return "settings.premium.message.active"
        case .notPurchased:
            return "settings.premium.message.not_purchased"
        }
    }
}
