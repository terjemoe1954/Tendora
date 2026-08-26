//
//  MainTabView.swift
//  Tendora
//
//  Created by Terje Moe on 22/08/2026.
//

import SwiftUI

private enum AppTab: Hashable {
    case home
    case calendar
    case add
    case documents
    case settings
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @State private var previousTab: AppTab = .home
    @State private var isPresentingAddAsset = false

    var body: some View {
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

            SettingsView()
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

    private func presentAddAsset() {
        isPresentingAddAsset = true
    }
}

#Preview {
    MainTabView()
}
