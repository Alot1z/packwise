import SwiftUI
import SwiftData

struct NewTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var title = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400*3)
    @State private var includeDates = false
    @State private var purpose = ""
    @State private var activities = ""
    @State private var climateInfo = ""
    @State private var notes = ""
    @State private var category = "General"

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !destination.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip") {
                    TextField("Title — for example, Kyoto in Spring", text: $title)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                    TextField("Destination", text: $destination)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                    Picker("Category", selection: $category) { ForEach(["General","Weekend","Work","Beach","Outdoor","International"], id: \.self) { Text($0).tag($0) } }
                    TextField("Purpose — business, leisure, family", text: $purpose)
                    TextField("Activities — hiking, meetings, dining", text: $activities)
                    TextField("Climate — e.g. Mild, 18°C, rainy season", text: $climateInfo)
                    TextField("Notes", text: $notes, axis: .vertical).lineLimit(2...4)
                }
                Section {
                    Toggle("Add dates", isOn: $includeDates)
                    if includeDates {
                        DatePicker("Start", selection: $startDate, displayedComponents: .date)
                        DatePicker("End", selection: $endDate, displayedComponents: .date)
                        if endDate < startDate {
                            Label("End date is before start date.", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption).foregroundStyle(Color(red: 0.72, green: 0.36, blue: 0.0))
                        }
                    }
                }
                Section {
                    Label("Stored locally. No account or connection required. You can add templates after creating the trip.", systemImage: "lock.shield")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let trip = Trip(
                            title: title.trimmingCharacters(in: .whitespaces),
                            destination: destination.trimmingCharacters(in: .whitespaces),
                            startDate: includeDates ? startDate : nil,
                            endDate: includeDates ? (endDate < startDate ? startDate : endDate) : nil,
                            purpose: purpose.isEmpty ? nil : purpose,
                            activities: activities.isEmpty ? nil : activities,
                            climateInfo: climateInfo.isEmpty ? nil : climateInfo,
                            notes: notes.isEmpty ? nil : notes,
                            tripCategory: category
                        )
                        context.insert(trip); try? context.save()
                        #if canImport(UIKit)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        #endif
                        dismiss()
                    }.disabled(!isValid)
                }
            }
        }
    }
}
