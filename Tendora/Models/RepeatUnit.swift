//
//  RepeatUnit.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import Foundation

enum RepeatUnit: String, CaseIterable, Codable, Identifiable {
    case days
    case weeks
    case months
    case years

    var id: String { rawValue }

    var displayNameLocalizationKey: String {
        switch self {
        case .days:
            return "repeat_unit.days"
        case .weeks:
            return "repeat_unit.weeks"
        case .months:
            return "repeat_unit.months"
        case .years:
            return "repeat_unit.years"
        }
    }

    var displayName: String {
        String(localized: String.LocalizationValue(displayNameLocalizationKey))
    }

    func displayName(locale: Locale) -> String {
        String(localized: String.LocalizationValue(displayNameLocalizationKey), locale: locale)
    }
}
