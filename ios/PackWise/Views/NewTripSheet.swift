import SwiftUI
import SwiftData

struct NewTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @StateObject private var destinationSearch = DestinationSearchService()
    @State private var title = ""
    @State private var destination = ""
    @State private var destinationLatitude: Double?
    @State private var destinationLongitude: Double?
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
                    if destinationSearch.isSearching {
                        ForEach(destinationSearch.suggestions, id: \.title) { completion in
                            Button {
                                let place = completion.title.isEmpty ? completion.subtitle : completion.title
                                destination = place
                                Task {
                                    if let coord = await destinationSearch.coordinate(for: completion) {
                                        destinationLatitude = coord.latitude
                                        destinationLongitude = coord.longitude
                                    }
                                }
                                destinationSearch.reset()
                            } label: {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse").foregroundStyle(.secondary)
                                    VStack(alignment: .leading) {
                                        Text(completion.title).font(.subheadline)
                                        if !completion.subtitle.isEmpty {
                                            Text(completion.subtitle).font(.caption).foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            .accessibilityLabel("\(completion.title), \(completion.subtitle)")
                            .accessibilityHint("Sets the destination")
                        }
                    }
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
            .onChange(of: destination) { _, v in
                destinationSearch.updateQuery(v)
            }
            .onDisappear { destinationSearch.reset() }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            // Geocode the destination if no suggestion was picked.
                            var lat = destinationLatitude
                            var lon = destinationLongitude
                            if lat == nil, lon == nil {
                                if let coord = await DestinationSearchService.geocode(destination: destination) {
                                    lat = coord.latitude
                                    lon = coord.longitude
                                }
                            }
                            let trip = Trip(
                                title: title.trimmingCharacters(in: .whitespaces),
                                destination: destination.trimmingCharacters(in: .whitespaces),
                                destinationLatitude: lat,
                                destinationLongitude: lon,
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
                        }
                    }.disabled(!isValid)
                }
            }
        }
    }
}
