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

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip") {
                    TextField("Title — for example, Kyoto in Spring", text: $title)
                    TextField("Destination", text: $destination)
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
                    }
                }
                Section { Text("Stored locally. No account or connection required.").font(.caption).foregroundStyle(.secondary) }
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
                            endDate: includeDates ? endDate : nil,
                            purpose: purpose.isEmpty ? nil : purpose,
                            activities: activities.isEmpty ? nil : activities,
                            climateInfo: climateInfo.isEmpty ? nil : climateInfo,
                            notes: notes.isEmpty ? nil : notes,
                            tripCategory: category
                        )
                        context.insert(trip); try? context.save(); dismiss()
                    }.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || destination.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
