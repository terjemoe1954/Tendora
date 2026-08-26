//
//  AddTaskView.swift
//  Tendora
//
//  Created by Codex on 24/08/2026.
//

import SwiftData
import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let asset: Asset
    private let taskToEdit: MaintenanceTask?

    @State private var title = ""
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
    @State private var repeatRule: RepeatRule = .never
    @State private var customRepeatValue = ""
    @State private var customRepeatUnit: RepeatUnit = .months
    @State private var reminderEnabled = true
    @State private var reminderOffset: ReminderOffset = .oneWeekBefore
    @State private var notes = ""
    @State private var alertState: AppAlertState?

    init(asset: Asset, taskToEdit: MaintenanceTask? = nil) {
        self.asset = asset
        self.taskToEdit = taskToEdit
        let defaultReminderOffset = ReminderOffset(rawValue: UserDefaults.standard.string(forKey: "defaultReminderOffset") ?? "") ?? .oneWeekBefore
        _title = State(initialValue: taskToEdit?.title ?? "")
        _dueDate = State(initialValue: taskToEdit?.dueDate ?? (Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now))
        _repeatRule = State(initialValue: taskToEdit?.repeatRule ?? .never)
        _customRepeatValue = State(initialValue: taskToEdit?.customRepeatValue.map(String.init) ?? "")
        _customRepeatUnit = State(initialValue: taskToEdit?.customRepeatUnit ?? .months)
        _reminderEnabled = State(initialValue: taskToEdit?.reminderEnabled ?? true)
        _reminderOffset = State(initialValue: taskToEdit?.reminderOffset ?? defaultReminderOffset)
        _notes = State(initialValue: taskToEdit?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("add_task.section.asset") {
                    LabeledContent(String(localized: "add_task.field.asset"), value: asset.name)
                }

                Section("add_task.section.details") {
                    TextField("add_task.field.title", text: $title)
                    TextField("add_task.field.notes", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }

                Section("add_task.section.schedule") {
                    DatePicker("add_task.field.due_date", selection: $dueDate, displayedComponents: .date)

                    Picker("add_task.field.repeat", selection: $repeatRule) {
                        ForEach(RepeatRule.allCases) { rule in
                            Text(rule.displayName).tag(rule)
                        }
                    }

                    if repeatRule == .custom {
                        TextField("add_task.field.custom_value", text: $customRepeatValue)
                            .keyboardType(.numberPad)

                        Picker("add_task.field.custom_unit", selection: $customRepeatUnit) {
                            ForEach(RepeatUnit.allCases) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                    }
                }

                Section("add_task.section.reminder") {
                    Toggle("add_task.field.reminder_enabled", isOn: $reminderEnabled)

                    if reminderEnabled {
                        Picker("add_task.field.reminder_timing", selection: $reminderOffset) {
                            ForEach(ReminderOffset.allCases) { offset in
                                Text(offset.displayName).tag(offset)
                            }
                        }
                    }
                }
            }
            .navigationTitle(taskToEdit == nil ? "add_task.title" : "edit_task.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("common.cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("common.save") {
                        Task {
                            await saveTask()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(isSaveDisabled)
                }
            }
            .alert(item: $alertState) { alert in
                Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text(String(localized: "common.ok"))))
            }
        }
    }

    private var isSaveDisabled: Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return true
        }

        if repeatRule == .custom {
            guard let value = Int(customRepeatValue) else {
                return true
            }

            return value <= 0
        }

        return false
    }

    private func saveTask() async {
        if let taskToEdit {
            taskToEdit.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            taskToEdit.dueDate = dueDate
            taskToEdit.notes = notes.trimmedNilIfEmpty
            taskToEdit.repeatRule = repeatRule
            taskToEdit.customRepeatValue = repeatRule == .custom ? Int(customRepeatValue) : nil
            taskToEdit.customRepeatUnit = repeatRule == .custom ? customRepeatUnit : nil
            taskToEdit.reminderEnabled = reminderEnabled
            taskToEdit.reminderOffset = reminderOffset
            taskToEdit.asset = asset
            do {
                try await updateNotification(for: taskToEdit)
            } catch {
                alertState = AppAlertState(
                    title: String(localized: "error.notifications.title"),
                    message: error.localizedDescription
                )
                return
            }
        } else {
            let task = MaintenanceTask(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                dueDate: dueDate,
                notes: notes.trimmedNilIfEmpty,
                repeatRule: repeatRule,
                customRepeatValue: repeatRule == .custom ? Int(customRepeatValue) : nil,
                customRepeatUnit: repeatRule == .custom ? customRepeatUnit : nil,
                reminderEnabled: reminderEnabled,
                reminderOffset: reminderOffset,
                asset: asset
            )

            modelContext.insert(task)
            do {
                try await updateNotification(for: task)
            } catch {
                alertState = AppAlertState(
                    title: String(localized: "error.notifications.title"),
                    message: error.localizedDescription
                )
                return
            }
        }
        dismiss()
    }

    private func updateNotification(for task: MaintenanceTask) async throws {
        if task.reminderEnabled {
            try await NotificationManager.shared.scheduleNotification(for: task)
        } else {
            await NotificationManager.shared.cancelNotification(for: task)
        }
    }
}

private extension String {
    var trimmedNilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

#Preview {
    AddTaskView(asset: PreviewSampleData.assets[0])
        .modelContainer(PreviewSampleData.container)
}
