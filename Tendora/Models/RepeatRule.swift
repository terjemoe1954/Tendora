//
//  RepeatRule.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import Foundation

enum RepeatRule: String, CaseIterable, Codable, Identifiable {
    case never
    case weekly
    case monthly
    case threeMonths
    case sixMonths
    case yearly
    case twoYears
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .never:
            return String(localized: "repeat_rule.never")
        case .weekly:
            return String(localized: "repeat_rule.weekly")
        case .monthly:
            return String(localized: "repeat_rule.monthly")
        case .threeMonths:
            return String(localized: "repeat_rule.three_months")
        case .sixMonths:
            return String(localized: "repeat_rule.six_months")
        case .yearly:
            return String(localized: "repeat_rule.yearly")
        case .twoYears:
            return String(localized: "repeat_rule.two_years")
        case .custom:
            return String(localized: "repeat_rule.custom")
        }
    }

    func nextDate(after date: Date, customValue: Int?, customUnit: RepeatUnit?, calendar: Calendar = .current) -> Date? {
        switch self {
        case .never:
            return nil
        case .weekly:
            return calendar.date(byAdding: .day, value: 7, to: date)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)
        case .threeMonths:
            return calendar.date(byAdding: .month, value: 3, to: date)
        case .sixMonths:
            return calendar.date(byAdding: .month, value: 6, to: date)
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date)
        case .twoYears:
            return calendar.date(byAdding: .year, value: 2, to: date)
        case .custom:
            guard let customValue, customValue > 0, let customUnit else { return nil }

            switch customUnit {
            case .days:
                return calendar.date(byAdding: .day, value: customValue, to: date)
            case .weeks:
                return calendar.date(byAdding: .day, value: customValue * 7, to: date)
            case .months:
                return calendar.date(byAdding: .month, value: customValue, to: date)
            case .years:
                return calendar.date(byAdding: .year, value: customValue, to: date)
            }
        }
    }
}
