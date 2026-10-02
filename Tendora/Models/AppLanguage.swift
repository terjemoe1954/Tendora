//
//  AppLanguage.swift
//  Tendora
//
//  Created by Codex on 05/09/2026.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english
    case norwegian
    case thai

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            return String(localized: "settings.language.system")
        case .english:
            return "English"
        case .norwegian:
            return "Norsk"
        case .thai:
            return "ไทย"
        }
    }

    var locale: Locale {
        switch self {
        case .system:
            return .autoupdatingCurrent
        case .english:
            return Locale(identifier: "en")
        case .norwegian:
            return Locale(identifier: "nb")
        case .thai:
            return Locale(identifier: "th")
        }
    }
}
