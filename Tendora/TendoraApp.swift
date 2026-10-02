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
    @State private var premiumEntitlementService = PremiumEntitlementService()
    private let modelContainerResult: Result<ModelContainer, Error>

    init() {
        NotificationManager.shared.configure()
        modelContainerResult = Self.makeSharedModelContainerResult()
    }

    var body: some Scene {
        WindowGroup {
            switch modelContainerResult {
            case .success(let sharedModelContainer):
                MainTabView()
                    .preferredColorScheme(selectedAppearance.colorScheme)
                    .environment(\.locale, selectedLanguage.locale)
                    .environment(premiumEntitlementService)
                    .modelContainer(sharedModelContainer)
                    .task {
                        await premiumEntitlementService.start()
                    }
                    .fullScreenCover(isPresented: onboardingBinding) {
                        OnboardingView {
                            hasSeenOnboarding = true
                        }
                    }
            case .failure(let error):
                StorageUnavailableView(error: error)
                    .preferredColorScheme(selectedAppearance.colorScheme)
                    .environment(\.locale, selectedLanguage.locale)
                    .environment(premiumEntitlementService)
                    .task {
                        await premiumEntitlementService.start()
                    }
            }
        }
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
    static func makeSharedModelContainerResult() -> Result<ModelContainer, Error> {
        do {
            return .success(try makeModelContainer())
        } catch {
            print("Unable to create CloudKit model container: \(error)")
            return .failure(error)
        }
    }
}

private struct StorageUnavailableView: View {
    let error: Error

    var body: some View {
        ContentUnavailableView {
            Label("storage_unavailable.title", systemImage: "externaldrive.badge.exclamationmark")
        } description: {
            Text("storage_unavailable.message")
        } actions: {
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
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
