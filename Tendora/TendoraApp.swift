//
//  TendoraApp.swift
//  Tendora
//
//  Created by Terje Moe on 22/08/2026.
//

import SwiftData
import SwiftUI

@main
struct TendoraApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("appAppearance") private var appAppearanceRawValue = AppAppearance.system.rawValue
    private let sharedModelContainer: ModelContainer

    init() {
        Self.resetPrereleaseStoreIfNeeded()
        NotificationManager.shared.configure()
        sharedModelContainer = Self.makeSharedModelContainer()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(selectedAppearance.colorScheme)
                .fullScreenCover(isPresented: onboardingBinding) {
                    OnboardingView {
                        hasSeenOnboarding = true
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private var onboardingBinding: Binding<Bool> {
        Binding(
            get: { hasSeenOnboarding == false },
            set: { isPresented in
                if isPresented == false {
                    hasSeenOnboarding = true
                }
            }
        )
    }

    private var selectedAppearance: AppAppearance {
        AppAppearance(rawValue: appAppearanceRawValue) ?? .system
    }
}

private extension TendoraApp {
    static let prereleaseStoreResetVersion = 1

    static func makeSharedModelContainer() -> ModelContainer {
        do {
            return try makeModelContainer()
        } catch {
            do {
                try resetDefaultStoreFiles()
                return try makeModelContainer()
            } catch {
                do {
                    return try makeInMemoryModelContainer()
                } catch {
                    fatalError("Unable to create model container: \(error)")
                }
            }
        }
    }

    static func resetPrereleaseStoreIfNeeded() {
        let defaults = UserDefaults.standard
        let storedVersion = defaults.integer(forKey: "dataResetVersion")
        guard storedVersion < Self.prereleaseStoreResetVersion else {
            return
        }

        try? resetDefaultStoreFiles()
        defaults.set(Self.prereleaseStoreResetVersion, forKey: "dataResetVersion")
    }
}

private func makeModelContainer() throws -> ModelContainer {
    let configuration = ModelConfiguration()
    return try ModelContainer(
        for: Asset.self,
        MaintenanceTask.self,
        CompletionRecord.self,
        Attachment.self,
        configurations: configuration
    )
}

private func makeInMemoryModelContainer() throws -> ModelContainer {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(
        for: Asset.self,
        MaintenanceTask.self,
        CompletionRecord.self,
        Attachment.self,
        configurations: configuration
    )
}

private func resetDefaultStoreFiles() throws {
    let fileManager = FileManager.default
    let applicationSupportURL = try fileManager.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )

    let defaultStoreURL = applicationSupportURL.appendingPathComponent("default.store")
    let relatedURLs = [
        defaultStoreURL,
        defaultStoreURL.appendingPathExtension("shm"),
        defaultStoreURL.appendingPathExtension("wal")
    ]

    for url in relatedURLs where fileManager.fileExists(atPath: url.path()) {
        try fileManager.removeItem(at: url)
    }
}
