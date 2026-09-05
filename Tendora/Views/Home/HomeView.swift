//
//  HomeView.swift
//  Tendora
//
//  Created by Terje Moe on 22/08/2026.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: \Asset.createdAt, order: .reverse) private var assets: [Asset]
    @Query(sort: \MaintenanceTask.dueDate, order: .forward) private var tasks: [MaintenanceTask]

    let onAddAsset: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if assets.isEmpty {
                    EmptyDashboardView(onAddAsset: onAddAsset)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            dashboardIntro
                            assetsSection
                            upcomingSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("app.name")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onAddAsset) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("home.add_asset.accessibility")
                }
            }
        }
    }

    private var dashboardIntro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("home.dashboard.tagline")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text("home.dashboard.intro")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var upcomingTasks: [MaintenanceTask] {
        tasks
            .filter { $0.isCompleted == false }
            .sorted { $0.dueDate < $1.dueDate }
    }

    private var assetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("home.assets.section_title")
                .font(.headline)

            ForEach(assets) { asset in
                NavigationLink {
                    AssetDetailView(asset: asset)
                } label: {
                    AssetCardView(asset: asset)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("home.upcoming.section_title")
                .font(.headline)

            if upcomingTasks.isEmpty {
                ContentUnavailableView(
                    "home.upcoming.empty_title",
                    systemImage: "checkmark.circle",
                    description: Text("home.upcoming.empty_message")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(upcomingTasks.prefix(4)) { task in
                        NavigationLink {
                            TaskDetailView(task: task)
                        } label: {
                            UpcomingTaskCard(task: task)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct EmptyDashboardView: View {
    let onAddAsset: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 104, height: 104)

                Image(systemName: "house.and.flag.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 8) {
                Text("home.empty.title")
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text("home.empty.message")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Button("home.empty.cta", action: onAddAsset)
                .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

private struct AssetCardView: View {
    let asset: Asset

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 56, height: 56)

                Image(systemName: asset.type.symbolName)
                    .font(.title3)
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(asset.cardSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

extension Asset {
    var cardSubtitle: String {
        let activeTaskCount = (tasks ?? []).filter { $0.isCompleted == false }.count

        if activeTaskCount > 0 {
            let format = String(localized: "asset.card.task_count")
            let taskSummary = String(format: format, locale: .current, activeTaskCount)

            if let nextTask = (tasks ?? [])
                .filter({ $0.isCompleted == false })
                .sorted(by: { $0.dueDate < $1.dueDate })
                .first
            {
                let dueFormat = String(localized: "asset.card.next_due")
                let dueSummary = String(format: dueFormat, locale: .current,
                    nextTask.title,
                    nextTask.dueDate.formatted(date: .abbreviated, time: .omitted)
                )
                return "\(taskSummary) • \(dueSummary)"
            }

            return taskSummary
        }

        if let metadata = primaryMetadata {
            return "\(type.displayName) • \(metadata)"
        }

        return type.displayName
    }

    var primaryMetadata: String? {
        switch type {
        case .home, .cabin:
            if let address, address.isEmpty == false {
                return address
            }
            if let year {
                let format = String(localized: "asset.metadata.built")
                return String(format: format, locale: .current, year)
            }
        case .car:
            let carSummary = [make, model]
                .compactMap { value in
                    guard let value, value.isEmpty == false else { return nil }
                    return value
                }
                .joined(separator: " ")

            if carSummary.isEmpty == false {
                return carSummary
            }

            if let registrationNumber, registrationNumber.isEmpty == false {
                return registrationNumber
            }
        case .boat:
            let boatSummary = [make, model]
                .compactMap { value in
                    guard let value, value.isEmpty == false else { return nil }
                    return value
                }
                .joined(separator: " ")

            if boatSummary.isEmpty == false {
                return boatSummary
            }
        case .other:
            break
        }

        if let notes, notes.isEmpty == false {
            return notes
        }

        return String(localized: "asset.metadata.empty")
    }
}

private struct UpcomingTaskCard: View {
    let task: MaintenanceTask

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)

                    if let assetName = task.asset?.name {
                        Text(assetName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text(task.statusLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(task.statusColor.opacity(0.14), in: Capsule())
                    .foregroundStyle(task.statusColor)
            }

            Text(String(format: String(localized: "home.upcoming.due_format"), locale: .current, task.dueDate.formatted(date: .abbreviated, time: .omitted)))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
} 

private extension MaintenanceTask {
    var statusColor: Color {
        if dueDate < .now {
            return .red
        }

        if Calendar.current.dateComponents([.day], from: .now, to: dueDate).day ?? 0 <= 7 {
            return .orange
        }

        return .green
    }

    var statusLabel: LocalizedStringKey {
        if dueDate < .now {
            return "task.status.overdue"
        }

        if Calendar.current.dateComponents([.day], from: .now, to: dueDate).day ?? 0 <= 7 {
            return "task.status.due_soon"
        }

        return "task.status.normal"
    }
}

#Preview {
    HomeView(onAddAsset: {})
        .modelContainer(PreviewSampleData.container)
}
