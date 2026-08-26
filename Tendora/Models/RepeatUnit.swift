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

    var displayName: String {
        switch self {
        case .days:
            return String(localized: "repeat_unit.days")
        case .weeks:
            return String(localized: "repeat_unit.weeks")
        case .months:
            return String(localized: "repeat_unit.months")
        case .years:
            return String(localized: "repeat_unit.years")
        }
    }
}
