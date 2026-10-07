//
//  MainTabView.swift
//  Tendora
//
//  Created by Terje Moe on 22/08/2026.
//

import SwiftData
import SwiftUI

private enum AppTab: Hashable {
    case home
    case calendar
    case add
    case documents
    case settings
}

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab: AppTab = .home
    @State private var previousTab: AppTab = .home
    @State private var isPresentingAddAsset = false
    @State private var isResettingUserData = false
    @State private var resetAlertState: MainDataResetAlertState?

    var body: some View {
        Group {
            if isResettingUserData {
                DataResetProgressView()
            } else {
                TabView(selection: $selectedTab) {
                    HomeView(onAddAsset: presentAddAsset)
                        .tabItem {
                            Label("tab.home", systemImage: "house")
                        }
                        .tag(AppTab.home)

                    CalendarView()
                        .tabItem {
                            Label("tab.calendar", systemImage: "calendar")
                        }
                        .tag(AppTab.calendar)

                    Color.clear
                        .tabItem {
                            Label("tab.add", systemImage: "plus.circle.fill")
                        }
                        .tag(AppTab.add)

                    DocumentsView()
                        .tabItem {
                            Label("tab.documents", systemImage: "doc.text")
                        }
                        .tag(AppTab.documents)

                    SettingsView(
                        isResettingData: isResettingUserData,
                        resetAllUserData: resetAllUserData
                    )
                    .tabItem {
                        Label("tab.settings", systemImage: "gearshape")
                    }
                    .tag(AppTab.settings)
                }
                .tint(.blue)
                .sheet(isPresented: $isPresentingAddAsset) {
                    AddAssetView()
                }
                .onChange(of: selectedTab) { _, newValue in
                    if newValue == .add {
                        selectedTab = previousTab
                        presentAddAsset()
                    } else {
                        previousTab = newValue
                    }
                }
            }
        }
        .alert(item: $resetAlertState) { alertState in
            Alert(
                title: Text(LocalizedStringKey(alertState.title)),
                message: Text(alertState.message),
                dismissButton: .default(Text("common.ok"))
            )
        }
    }

    private func resetAllUserData() async {
        guard isResettingUserData == false else {
            return
        }

        isResettingUserData = true
        isPresentingAddAsset = false

        await Task.yield()
        try? await Task.sleep(for: .milliseconds(250))

        do {
            let summary = try await DataResetService.shared.resetAllUserData(in: modelContext)
            let message = String(
                localized: "settings.reset.success.message \(summary.assetCount) \(summary.taskCount) \(summary.attachmentCount)"
            )
            resetAlertState = MainDataResetAlertState(
                title: "settings.reset.success.title",
                message: message
            )
        } catch {
            resetAlertState = MainDataResetAlertState(
                title: "settings.reset.error.title",
                message: error.localizedDescription
            )
        }

        selectedTab = .home
        previousTab = .home
        isResettingUserData = false
    }

    private func presentAddAsset() {
        isPresentingAddAsset = true
    }
}

private struct DataResetProgressView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()

            Text("settings.reset.in_progress")
                .font(.headline)

            Text("settings.reset.progress.message")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

private struct MainDataResetAlertState: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

#Preview {
    MainTabView()
}
