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
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 140, height: 140)

                Image(systemName: "house.and.flag.fill")
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 12) {
                Text("onboarding.page1.title")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)

                Text("onboarding.page1.message")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 8)

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
}

#Preview {
    OnboardingView(onGetStarted: {})
}
