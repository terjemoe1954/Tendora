//
//  AddAssetView.swift
//  Tendora
//
//  Created by Terje Moe on 22/08/2026.
//

import SwiftData
import SwiftUI

struct AddAssetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let assetToEdit: Asset?

    @State private var selectedType: AssetType = .home
    @State private var name = ""
    @State private var notes = ""
    @State private var make = ""
    @State private var model = ""
    @State private var yearText = ""
    @State private var fuelType = ""
    @State private var odometerText = ""
    @State private var registrationNumber = ""
    @State private var address = ""
    @State private var alertState: AppAlertState?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    init(assetToEdit: Asset? = nil) {
        self.assetToEdit = assetToEdit
        _selectedType = State(initialValue: assetToEdit?.type ?? .home)
        _name = State(initialValue: assetToEdit?.name ?? "")
        _notes = State(initialValue: assetToEdit?.notes ?? "")
        _make = State(initialValue: assetToEdit?.make ?? "")
        _model = State(initialValue: assetToEdit?.model ?? "")
        _yearText = State(initialValue: assetToEdit?.year.map(String.init) ?? "")
        _fuelType = State(initialValue: assetToEdit?.fuelType ?? "")
        _odometerText = State(initialValue: assetToEdit?.odometer.map { String(Int($0)) } ?? "")
        _registrationNumber = State(initialValue: assetToEdit?.registrationNumber ?? "")
        _address = State(initialValue: assetToEdit?.address ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("add_asset.prompt")
                            .font(.headline)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(AssetType.allCases) { type in
                                assetTypeButton(for: type)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("add_asset.section.details") {
                    TextField("add_asset.field.name", text: $name)
                    TextField("add_asset.field.notes", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }

                if selectedType == .home || selectedType == .cabin {
                    Section("add_asset.section.location") {
                        TextField("add_asset.field.address", text: $address)
                        TextField("add_asset.field.year_built", text: $yearText)
                            .keyboardType(.numberPad)
                    }
                }

                if selectedType == .car {
                    Section("add_asset.section.vehicle") {
                        TextField("add_asset.field.make", text: $make)
                        TextField("add_asset.field.model", text: $model)
                        TextField("add_asset.field.year", text: $yearText)
                            .keyboardType(.numberPad)
                        TextField("add_asset.field.fuel_type", text: $fuelType)
                        TextField("add_asset.field.current_odometer", text: $odometerText)
                            .keyboardType(.decimalPad)
                        TextField("add_asset.field.registration_number", text: $registrationNumber)
                            .textInputAutocapitalization(.characters)
                    }
                }

                if selectedType == .boat {
                    Section("add_asset.section.boat") {
                        TextField("add_asset.field.make", text: $make)
                        TextField("add_asset.field.model", text: $model)
                        TextField("add_asset.field.year", text: $yearText)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle(assetToEdit == nil ? "add_asset.title" : "edit_asset.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("common.cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("common.save") {
                        saveAsset()
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
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return true
        }

        if yearText.trimmedNilIfEmpty != nil, Int(yearText) == nil {
            return true
        }

        if selectedType == .car {
            guard let odometerValue = parsedOdometer else {
                return odometerText.trimmedNilIfEmpty != nil
            }

            return odometerValue < 0
        }

        return false
    }

    @ViewBuilder
    private func assetTypeButton(for type: AssetType) -> some View {
        Button {
            selectedType = type
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: type.symbolName)
                    .font(.headline)
                    .foregroundStyle(selectedType == type ? Color.white : Color.accentColor)

                Text(LocalizedStringKey(type.selectionTitleLocalizationKey))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(selectedType == type ? Color.white : Color.primary)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(selectedType == type ? Color.accentColor : Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
    }

    private func saveAsset() {
        guard let input = validatedInput else {
            return
        }

        do {
            if let assetToEdit {
                assetToEdit.name = input.name
                assetToEdit.type = selectedType
                assetToEdit.notes = input.notes
                assetToEdit.make = input.make
                assetToEdit.model = input.model
                assetToEdit.year = input.year
                assetToEdit.fuelType = input.fuelType
                assetToEdit.odometer = input.odometer
                assetToEdit.registrationNumber = input.registrationNumber
                assetToEdit.address = input.address
            } else {
                let asset = Asset(
                    name: input.name,
                    type: selectedType,
                    notes: input.notes,
                    make: input.make,
                    model: input.model,
                    year: input.year,
                    fuelType: input.fuelType,
                    odometer: input.odometer,
                    registrationNumber: input.registrationNumber,
                    address: input.address
                )

                modelContext.insert(asset)
            }

            try modelContext.save()
            dismiss()
        } catch {
            alertState = AppAlertState(
                title: String(localized: "error.data.title"),
                message: String(localized: "error.data.save_failed.message")
            )
        }
    }

    private var parsedOdometer: Double? {
        guard let trimmed = odometerText.trimmedNilIfEmpty else {
            return nil
        }

        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }

    private var validatedInput: AssetInput? {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedName.isEmpty == false else {
            return nil
        }

        let parsedYear: Int?
        if let yearString = yearText.trimmedNilIfEmpty {
            guard let value = Int(yearString) else {
                presentValidationError(message: String(localized: "error.assets.invalid_year.message"))
                return nil
            }
            parsedYear = value
        } else {
            parsedYear = nil
        }

        let parsedOdometerValue: Double?
        if selectedType == .car, let odometerString = odometerText.trimmedNilIfEmpty {
            guard let value = Double(odometerString.replacingOccurrences(of: ",", with: ".")), value >= 0 else {
                presentValidationError(message: String(localized: "error.assets.invalid_odometer.message"))
                return nil
            }
            parsedOdometerValue = value
        } else {
            parsedOdometerValue = nil
        }

        return AssetInput(
            name: normalizedName,
            notes: notes.trimmedNilIfEmpty,
            make: selectedType == .car || selectedType == .boat ? make.trimmedNilIfEmpty : nil,
            model: selectedType == .car || selectedType == .boat ? model.trimmedNilIfEmpty : nil,
            year: selectedType == .home || selectedType == .cabin || selectedType == .car || selectedType == .boat ? parsedYear : nil,
            fuelType: selectedType == .car ? fuelType.trimmedNilIfEmpty : nil,
            odometer: selectedType == .car ? parsedOdometerValue : nil,
            registrationNumber: selectedType == .car ? registrationNumber.trimmedNilIfEmpty : nil,
            address: selectedType == .home || selectedType == .cabin ? address.trimmedNilIfEmpty : nil
        )
    }

    private func presentValidationError(message: String) {
        alertState = AppAlertState(
            title: String(localized: "error.assets.title"),
            message: message
        )
    }
}

private struct AssetInput {
    let name: String
    let notes: String?
    let make: String?
    let model: String?
    let year: Int?
    let fuelType: String?
    let odometer: Double?
    let registrationNumber: String?
    let address: String?
}

private extension String {
    var trimmedNilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
