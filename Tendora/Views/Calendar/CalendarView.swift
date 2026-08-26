//
//  CalendarView.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import SwiftData
import SwiftUI

struct CalendarView: View {
    @Query(sort: \MaintenanceTask.dueDate, order: .forward) private var tasks: [MaintenanceTask]
    @State private var selectedDate = Date()

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    monthSummaryCard
                    calendarPicker
                    selectedDaySection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("tab.calendar")
        }
    }

    private var activeTasks: [MaintenanceTask] {
        tasks.filter { $0.isCompleted == false }
    }

    private var selectedDayTasks: [MaintenanceTask] {
        activeTasks.filter { calendar.isDate($0.dueDate, inSameDayAs: selectedDate) }
    }

    private var currentMonthTasks: [MaintenanceTask] {
        activeTasks.filter {
            calendar.isDate($0.dueDate, equalTo: selectedDate, toGranularity: .month) &&
            calendar.isDate($0.dueDate, equalTo: selectedDate, toGranularity: .year)
        }
    }

    private var monthSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                .font(.title2.weight(.semibold))

            Text(String(format: String(localized: "calendar.summary.tasks_due"), locale: .current, currentMonthTasks.count))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let nextTask = currentMonthTasks.sorted(by: { $0.dueDate < $1.dueDate }).first {
                VStack(alignment: .leading, spacing: 4) {
                    Text(nextTask.title)
                        .font(.headline)

                    Text(
                        String(
                            format: String(localized: "calendar.summary.next_due"),
                            locale: .current,
                            nextTask.asset?.name ?? String(localized: "app.name"),
                            nextTask.dueDate.formatted(date: .abbreviated, time: .omitted)
                        )
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var calendarPicker: some View {
        DatePicker(
            "calendar.selected_day",
            selection: $selectedDate,
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var selectedDaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedDate.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                .font(.headline)

            if selectedDayTasks.isEmpty {
                ContentUnavailableView(
                    "calendar.empty.title",
                    systemImage: "calendar.badge.checkmark",
                    description: Text("calendar.empty.message")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(selectedDayTasks) { task in
                        NavigationLink {
                            TaskDetailView(task: task)
                        } label: {
                            CalendarTaskCard(task: task)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct CalendarTaskCard: View {
    let task: MaintenanceTask

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let assetName = task.asset?.name {
                    Text(assetName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(task.repeatSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(task.statusLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(task.statusColor.opacity(0.14), in: Capsule())
                    .foregroundStyle(task.statusColor)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
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
    CalendarView()
        .modelContainer(PreviewSampleData.container)
}
