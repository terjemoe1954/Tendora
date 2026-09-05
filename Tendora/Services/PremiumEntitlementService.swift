//
//  PremiumEntitlementService.swift
//  Tendora
//
//  Created by Codex on 05/09/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class PremiumEntitlementService {
    static let monthlyProductID = "tendora_premium_monthly"
    static let yearlyProductID = "tendora_premium_yearly"

    private let userDefaults: UserDefaults
    private let premiumUnlockedKey = "premiumEntitlementUnlocked"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var isPremiumUnlocked: Bool {
        userDefaults.bool(forKey: premiumUnlockedKey)
    }

    var status: PremiumEntitlementStatus {
        isPremiumUnlocked ? .active : .notPurchased
    }
}

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
