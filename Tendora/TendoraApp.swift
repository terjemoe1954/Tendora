//
//  TendoraApp.swift
//  Tendora
//
//  Created by Terje Moe on 22/08/2026.
//

import SwiftData
import SwiftUI

private let tendoraCloudKitContainerIdentifier = "iCloud.com.terjemoe.Tendora"

@main
struct TendoraApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("appAppearance") private var appAppearanceRawValue = AppAppearance.system.rawValue
    @AppStorage("appLanguage") private var appLanguageRawValue = AppLanguage.system.rawValue
    private let sharedModelContainer: ModelContainer

    init() {
        NotificationManager.shared.configure()
        sharedModelContainer = Self.makeSharedModelContainer()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(selectedAppearance.colorScheme)
                .environment(\.locale, selectedLanguage.locale)
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

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: appLanguageRawValue) ?? .system
    }
}

private extension TendoraApp {
    static func makeSharedModelContainer() -> ModelContainer {
        do {
            return try makeModelContainer()
        } catch {
            print("Unable to create CloudKit model container: \(error)")
            do {
                return try makeInMemoryModelContainer()
            } catch {
                fatalError("Unable to create model container: \(error)")
            }
        }
    }
}

private func makeModelContainer() throws -> ModelContainer {
    let configuration = ModelConfiguration(
        cloudKitDatabase: .private(tendoraCloudKitContainerIdentifier)
    )
    return try ModelContainer(
        for: Asset.self,
        MaintenanceTask.self,
        CompletionRecord.self,
        Attachment.self,
        migrationPlan: TendoraMigrationPlan.self,
        configurations: configuration
    )
}

private func makeInMemoryModelContainer() throws -> ModelContainer {
    let configuration = ModelConfiguration(
        "Fallback",
        schema: Schema([Asset.self, MaintenanceTask.self, CompletionRecord.self, Attachment.self]),
        isStoredInMemoryOnly: true,
        allowsSave: true,
        cloudKitDatabase: .none
    )
    return try ModelContainer(
        for: Asset.self,
        MaintenanceTask.self,
        CompletionRecord.self,
        Attachment.self,
        configurations: configuration
    )
}
