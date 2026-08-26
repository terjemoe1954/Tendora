//
//  OnboardingView.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import SwiftUI

struct OnboardingView: View {
    let onGetStarted: () -> Void

    var body: some View {
        TabView {
            OnboardingPageView(
                titleKey: "onboarding.page1.title",
                messageKey: "onboarding.page1.message",
                systemImage: "house.and.flag.fill"
            )

            OnboardingPageView(
                titleKey: "onboarding.page2.title",
                messageKey: "onboarding.page2.message",
                systemImage: "bell.badge.fill"
            )

            VStack(spacing: 28) {
                Spacer()

                OnboardingPageView(
                    titleKey: "onboarding.page3.title",
                    messageKey: "onboarding.page3.message",
                    systemImage: "tray.full.fill"
                )

                Button("onboarding.cta", action: onGetStarted)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 40)
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color.blue.opacity(0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Color(.systemBackground))
    }
}

private struct OnboardingPageView: View {
    let titleKey: LocalizedStringKey
    let messageKey: LocalizedStringKey
    let systemImage: String

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 140, height: 140)

                Image(systemName: systemImage)
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 12) {
                Text(titleKey)
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)

                Text(messageKey)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 8)

            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 40)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color.blue.opacity(0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    OnboardingView(onGetStarted: {})
}
