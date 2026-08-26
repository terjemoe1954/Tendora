//
//  AppAppearance.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            return String(localized: "settings.appearance.system")
        case .light:
            return String(localized: "settings.appearance.light")
        case .dark:
            return String(localized: "settings.appearance.dark")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
