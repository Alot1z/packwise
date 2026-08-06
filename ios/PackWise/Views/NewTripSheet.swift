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

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip") {
                    TextField("Title — for example, Kyoto in Spring", text: $title)
                    TextField("Destination", text: $destination)
                    TextField("Purpose — business, leisure, family", text: $purpose)
                }
                Section {
                    Toggle("Add dates", isOn: $includeDates)
                    if includeDates {
                        DatePicker("Start", selection: $startDate, displayedComponents: .date)
                        DatePicker("End", selection: $endDate, displayedComponents: .date)
                    }
                }
                Section {
                    Text("Stored locally. No account or connection required.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let trip = Trip(title: title.trimmingCharacters(in: .whitespaces),
                                        destination: destination.trimmingCharacters(in: .whitespaces),
                                        startDate: includeDates ? startDate : nil,
                                        endDate: includeDates ? endDate : nil,
                                        purpose: purpose.isEmpty ? nil : purpose)
                        context.insert(trip)
                        try? context.save()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || destination.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
