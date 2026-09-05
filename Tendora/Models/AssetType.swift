//
//  AssetType.swift
//  Tendora
//
//  Created by Terje Moe on 22/08/2026.
//

import Foundation

enum AssetType: String, CaseIterable, Codable, Identifiable {
    case home
    case cabin
    case car
    case boat
    case other

    var id: String { rawValue }

    var displayNameLocalizationKey: String {
        switch self {
        case .home:
            return "asset_type.home.display_name"
        case .cabin:
            return "asset_type.cabin.display_name"
        case .car:
            return "asset_type.car.display_name"
        case .boat:
            return "asset_type.boat.display_name"
        case .other:
            return "asset_type.other.display_name"
        }
    }

    var selectionTitleLocalizationKey: String {
        switch self {
        case .home:
            return "asset_type.home.selection_title"
        case .cabin:
            return "asset_type.cabin.selection_title"
        case .car:
            return "asset_type.car.selection_title"
        case .boat:
            return "asset_type.boat.selection_title"
        case .other:
            return "asset_type.other.selection_title"
        }
    }

    var displayName: String {
        String(localized: String.LocalizationValue(displayNameLocalizationKey))
    }

    var selectionTitle: String {
        String(localized: String.LocalizationValue(selectionTitleLocalizationKey))
    }

    var symbolName: String {
        switch self {
        case .home:
            return "house.fill"
        case .cabin:
            return "tree.fill"
        case .car:
            return "car.fill"
        case .boat:
            return "sailboat.fill"
        case .other:
            return "square.grid.2x2.fill"
        }
    }
}
