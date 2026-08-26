//
//  ReminderOffset.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import Foundation

enum ReminderOffset: String, CaseIterable, Codable, Identifiable {
    case sameDay
    case oneDayBefore
    case threeDaysBefore
    case oneWeekBefore
    case twoWeeksBefore
    case oneMonthBefore

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sameDay:
            return String(localized: "reminder_offset.same_day")
        case .oneDayBefore:
            return String(localized: "reminder_offset.one_day_before")
        case .threeDaysBefore:
            return String(localized: "reminder_offset.three_days_before")
        case .oneWeekBefore:
            return String(localized: "reminder_offset.one_week_before")
        case .twoWeeksBefore:
            return String(localized: "reminder_offset.two_weeks_before")
        case .oneMonthBefore:
            return String(localized: "reminder_offset.one_month_before")
        }
    }

    func triggerDate(for dueDate: Date, calendar: Calendar = .current) -> Date? {
        switch self {
        case .sameDay:
            return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: dueDate)
        case .oneDayBefore:
            return calendar.date(byAdding: .day, value: -1, to: dueDate).flatMap {
                calendar.date(bySettingHour: 9, minute: 0, second: 0, of: $0)
            }
        case .threeDaysBefore:
            return calendar.date(byAdding: .day, value: -3, to: dueDate).flatMap {
                calendar.date(bySettingHour: 9, minute: 0, second: 0, of: $0)
            }
        case .oneWeekBefore:
            return calendar.date(byAdding: .day, value: -7, to: dueDate).flatMap {
                calendar.date(bySettingHour: 9, minute: 0, second: 0, of: $0)
            }
        case .twoWeeksBefore:
            return calendar.date(byAdding: .day, value: -14, to: dueDate).flatMap {
                calendar.date(bySettingHour: 9, minute: 0, second: 0, of: $0)
            }
        case .oneMonthBefore:
            return calendar.date(byAdding: .month, value: -1, to: dueDate).flatMap {
                calendar.date(bySettingHour: 9, minute: 0, second: 0, of: $0)
            }
        }
    }
}
