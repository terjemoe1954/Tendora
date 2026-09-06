//
//  CalendarView.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import SwiftData
import SwiftUI

struct CalendarView: View {
    @Environment(\.locale) private var locale

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
            Text(selectedDate.formatted(.dateTime.locale(locale).month(.wide).year()))
                .font(.title2.weight(.semibold))

            Text(String(format: String(localized: "calendar.summary.tasks_due", locale: locale), locale: locale, currentMonthTasks.count))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let nextTask = currentMonthTasks.sorted(by: { $0.dueDate < $1.dueDate }).first {
                VStack(alignment: .leading, spacing: 4) {
                    Text(nextTask.title)
                        .font(.headline)

                    Text(
                        String(
                            format: String(localized: "calendar.summary.next_due", locale: locale),
                            locale: locale,
                            nextTask.asset?.name ?? String(localized: "app.name", locale: locale),
                            nextTask.dueDate.formatted(.dateTime.locale(locale).day().month().year())
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
        TaskMonthCalendar(
            selectedDate: $selectedDate,
            activeTaskDates: activeTasks.map(\.dueDate)
        )
    }

    private var selectedDaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedDate.formatted(.dateTime.locale(locale).weekday(.wide).day().month(.wide)))
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

private struct TaskMonthCalendar: View {
    @Environment(\.locale) private var locale

    @Binding var selectedDate: Date
    let activeTaskDates: [Date]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Button {
                    moveMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Previous month")

                Spacer()

                Text(selectedDate.formatted(.dateTime.locale(locale).month(.wide).year()))
                    .font(.headline)

                Spacer()

                Button {
                    moveMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Next month")
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(calendarDays) { day in
                    if let date = day.date {
                        CalendarDayButton(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            hasActiveTask: hasActiveTask(on: date),
                            calendar: calendar
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 38)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = locale
        return calendar
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let firstIndex = calendar.firstWeekday - 1
        return Array(symbols[firstIndex...] + symbols[..<firstIndex])
    }

    private var calendarDays: [CalendarDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let dayRange = calendar.range(of: .day, in: .month, for: selectedDate)
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingEmptyDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        let emptyDays = (0..<leadingEmptyDays).map { CalendarDay(id: "empty-\($0)", date: nil) }
        let days = dayRange.compactMap { day -> CalendarDay? in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) else {
                return nil
            }
            return CalendarDay(id: "day-\(day)", date: date)
        }

        return emptyDays + days
    }

    private func hasActiveTask(on date: Date) -> Bool {
        activeTaskDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }

    private func moveMonth(by value: Int) {
        if let date = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = date
        }
    }
}

private struct CalendarDay: Identifiable {
    let id: String
    let date: Date?
}

private struct CalendarDayButton: View {
    let date: Date
    let isSelected: Bool
    let hasActiveTask: Bool
    let calendar: Calendar
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(calendar.component(.day, from: date))")
                .font(.subheadline.weight(isSelected || hasActiveTask ? .semibold : .regular))
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(backgroundShape)
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        if isSelected || hasActiveTask {
            return .white
        }
        return .primary
    }

    @ViewBuilder
    private var backgroundShape: some View {
        if isSelected {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 34, height: 34)
        } else if hasActiveTask {
            Circle()
                .fill(Color.orange)
                .frame(width: 34, height: 34)
        }
    }
}

private struct CalendarTaskCard: View {
    @Environment(\.locale) private var locale

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

                Text(task.repeatSummary(locale: locale))
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
