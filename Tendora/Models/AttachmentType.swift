//
//  AttachmentType.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import Foundation

enum AttachmentType: String, CaseIterable, Codable, Identifiable {
    case photo
    case receipt
    case invoice
    case manual
    case warranty
    case insurance
    case serviceRecord
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .photo:
            return String(localized: "attachment_type.photo")
        case .receipt:
            return String(localized: "attachment_type.receipt")
        case .invoice:
            return String(localized: "attachment_type.invoice")
        case .manual:
            return String(localized: "attachment_type.manual")
        case .warranty:
            return String(localized: "attachment_type.warranty")
        case .insurance:
            return String(localized: "attachment_type.insurance")
        case .serviceRecord:
            return String(localized: "attachment_type.service_record")
        case .other:
            return String(localized: "attachment_type.other")
        }
    }

    var symbolName: String {
        switch self {
        case .photo:
            return "photo"
        case .receipt, .invoice:
            return "receipt"
        case .manual:
            return "book.closed"
        case .warranty:
            return "checkmark.shield"
        case .insurance:
            return "shield"
        case .serviceRecord:
            return "wrench.and.screwdriver"
        case .other:
            return "doc"
        }
    }
}
