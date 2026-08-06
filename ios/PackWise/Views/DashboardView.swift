import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]

    var upcoming: [Trip] {
        trips.filter { $0.status != .archived }.prefix(5).map { $0 }
    }

    var body: some View {
        NavigationStack {
            List {
                if trips.isEmpty {
                    Section {
                        ContentUnavailableView("Welcome to PackWise", systemImage: "suitcase", description: Text("Create your first trip to see progress, reminders, and quick actions here."))
                    }
                } else {
                    Section("Upcoming") {
                        ForEach(upcoming) { trip in
                            NavigationLink(value: trip) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(trip.title).font(.subheadline.weight(.medium))
                                        Text(trip.destination).font(.caption).foregroundStyle(.secondary)
                                        if trip.essentialsMissing > 0 {
                                            Text("\(trip.essentialsMissing) essentials still unpacked").font(.caption2).foregroundStyle(.orange)
                                        }
                                    }
                                    Spacer()
                                    ProgressView(value: trip.progress).frame(width: 44)
                                    Text("\(Int(trip.progress*100))%").font(.caption2.monospaced()).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    Section("Packing progress") {
                        ForEach(trips.filter { !$0.items.isEmpty }.prefix(4)) { trip in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack { Text(trip.title).font(.caption.weight(.medium)); Spacer(); Text(trip.status.label).font(.caption2).foregroundStyle(.secondary) }
                                ProgressView(value: trip.progress)
                                Text("\(trip.items.filter(\.packed).count)/\(trip.items.count) packed").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                        if trips.allSatisfy(\.items.isEmpty) {
                            Text("Add items to any trip to see progress here.").font(.caption).foregroundStyle(.secondary)
                        }
                    }

                    Section("Quick actions") {
                        NavigationLink("Create trip", value: "createTrip")
                        NavigationLink("Open Templates", value: "templates")
                        NavigationLink("Photo Scanner", value: "scanner")
                    }

                    Section("Recent activity") {
                        ForEach(trips.sorted(by: { $0.updatedAt > $1.updatedAt }).prefix(3)) { trip in
                            LabeledContent(trip.title, value: trip.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Dashboard")
            .navigationDestination(for: Trip.self) { TripDetailView(trip: $0) }
            .navigationDestination(for: String.self) { key in
                if key == "createTrip" { Text("Use Trips → New trip") }
                else if key == "templates" { TemplateLibraryView() }
                else if key == "scanner" { PhotoScannerView() }
            }
        }
    }
}
