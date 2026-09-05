//
//  CloudSyncStatusService.swift
//  Tendora
//
//  Created by Codex on 05/09/2026.
//

import CloudKit
import Foundation
import Observation

@MainActor
@Observable
final class CloudSyncStatusService {
    private(set) var status: CloudSyncStatus = .checking

    func refresh() async {
        let result = await Self.fetchAccountStatus()
        status = CloudSyncStatus(accountStatus: result.status, error: result.error)
    }

    private static func fetchAccountStatus() async -> (status: CKAccountStatus, error: Error?) {
        await withCheckedContinuation { continuation in
            CKContainer(identifier: "iCloud.com.terjemoe.Tendora").accountStatus { status, error in
                continuation.resume(returning: (status, error))
            }
        }
    }
}

enum CloudSyncStatus: Equatable {
    case checking
    case available
    case noAccount
    case restricted
    case temporarilyUnavailable
    case unavailable

    init(accountStatus: CKAccountStatus, error: Error?) {
        if error != nil {
            self = .unavailable
            return
        }

        switch accountStatus {
        case .available:
            self = .available
        case .noAccount:
            self = .noAccount
        case .restricted:
            self = .restricted
        case .temporarilyUnavailable:
            self = .temporarilyUnavailable
        case .couldNotDetermine:
            self = .unavailable
        @unknown default:
            self = .unavailable
        }
    }

    var title: String {
        switch self {
        case .checking:
            return String(localized: "settings.sync.status.checking")
        case .available:
            return String(localized: "settings.sync.status.available")
        case .noAccount:
            return String(localized: "settings.sync.status.no_account")
        case .restricted:
            return String(localized: "settings.sync.status.restricted")
        case .temporarilyUnavailable:
            return String(localized: "settings.sync.status.temporarily_unavailable")
        case .unavailable:
            return String(localized: "settings.sync.status.unavailable")
        }
    }

    var message: String {
        switch self {
        case .checking:
            return String(localized: "settings.sync.message.checking")
        case .available:
            return String(localized: "settings.sync.message.available")
        case .noAccount:
            return String(localized: "settings.sync.message.no_account")
        case .restricted:
            return String(localized: "settings.sync.message.restricted")
        case .temporarilyUnavailable:
            return String(localized: "settings.sync.message.temporarily_unavailable")
        case .unavailable:
            return String(localized: "settings.sync.message.unavailable")
        }
    }
}
