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
    @AppStorage("dataResetVersion") private var dataResetVersion = 0

    private let sharedModelContainer: ModelContainer = {
        let schema = Schema(versionedSchema: TendoraSchemaV2.self)

        do {
            return try makeModelContainer(for: schema)
        } catch {
            fatalError("Unable to create model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .id(dataResetVersion)
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

private func makeModelContainer(for schema: Schema) throws -> ModelContainer {
    let configuration = ModelConfiguration(schema: schema)

    do {
        return try ModelContainer(
            for: schema,
            migrationPlan: TendoraMigrationPlan.self,
            configurations: [configuration]
        )
    } catch {
        try resetDefaultStoreFiles()
        return try ModelContainer(
            for: schema,
            migrationPlan: TendoraMigrationPlan.self,
            configurations: [configuration]
        )
    }
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
