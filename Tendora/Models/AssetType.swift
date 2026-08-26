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

    var displayName: String {
        switch self {
        case .home:
            return String(localized: "asset_type.home.display_name")
        case .cabin:
            return String(localized: "asset_type.cabin.display_name")
        case .car:
            return String(localized: "asset_type.car.display_name")
        case .boat:
            return String(localized: "asset_type.boat.display_name")
        case .other:
            return String(localized: "asset_type.other.display_name")
        }
    }

    var selectionTitle: String {
        switch self {
        case .home:
            return String(localized: "asset_type.home.selection_title")
        case .cabin:
            return String(localized: "asset_type.cabin.selection_title")
        case .car:
            return String(localized: "asset_type.car.selection_title")
        case .boat:
            return String(localized: "asset_type.boat.selection_title")
        case .other:
            return String(localized: "asset_type.other.selection_title")
        }
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
