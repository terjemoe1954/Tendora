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
    case contract
    case registrationDocument
    case serviceRecord
    case other

    var id: String { rawValue }

    var displayNameLocalizationKey: String {
        switch self {
        case .photo:
            return "attachment_type.photo"
        case .receipt:
            return "attachment_type.receipt"
        case .invoice:
            return "attachment_type.invoice"
        case .manual:
            return "attachment_type.manual"
        case .warranty:
            return "attachment_type.warranty"
        case .insurance:
            return "attachment_type.insurance"
        case .contract:
            return "attachment_type.contract"
        case .registrationDocument:
            return "attachment_type.registration_document"
        case .serviceRecord:
            return "attachment_type.service_record"
        case .other:
            return "attachment_type.other"
        }
    }

    var displayName: String {
        String(localized: String.LocalizationValue(displayNameLocalizationKey))
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
        case .contract:
            return "doc.text"
        case .registrationDocument:
            return "car.text"
        case .serviceRecord:
            return "wrench.and.screwdriver"
        case .other:
            return "doc"
        }
    }
}
