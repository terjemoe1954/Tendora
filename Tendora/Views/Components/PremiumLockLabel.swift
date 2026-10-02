//
//  PremiumLockLabel.swift
//  Tendora
//
//  Created by Codex on 26/09/2026.
//

import SwiftUI

struct PremiumLockLabel: View {
    var body: some View {
        Label("premium.locked.label", systemImage: "lock.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .labelStyle(.titleAndIcon)
            .accessibilityLabel("premium.locked.accessibility")
    }
}

#Preview {
    PremiumLockLabel()
}
