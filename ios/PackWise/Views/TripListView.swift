import SwiftUI
import SwiftData

struct TripListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]
    @Binding var selectedTrip: Trip?
    @State private var showNew = false
    @State private var search = ""

    var filtered: [Trip] {
        guard !search.isEmpty else { return trips }
        let q = search.lowercased()
        return trips.filter { $0.title.lowercased().contains(q) || $0.destination.lowercased().contains(q) || ($0.notes?.lowercased().contains(q) ?? false) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    ContentUnavailableView {
                        Label("Pack with precision", systemImage: "suitcase")
                    } description: {
                        Text("Create your first trip to unlock your private dashboard, detailed item views, and day-by-day outfit planning. Everything stays on device and works offline.")
                    } actions: {
                        Button("Create your first trip") { showNew = true }.buttonStyle(.borderedProminent)
                    }
                } else {
                    List(filtered) { trip in
                        NavigationLink(value: trip) { TripRow(trip: trip) }
                    }
                    .listStyle(.insetGrouped)
                    .navigationDestination(for: Trip.self) { TripDetailView(trip: $0) }
                    .navigationDestination(for: PackingItem.self) { ItemDetailView(item: $0) }
                }
            }
            .navigationTitle("Trips")
            .searchable(text: $search, prompt: "Search trips — destinations, dates, notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button { showNew = true } label: { Label("New trip", systemImage: "plus") } }
                ToolbarItem(placement: .topBarLeading) { NavigationLink(value: "dashboard") { Label("Dashboard", systemImage: "rectangle.grid.2x2") } }
            }
            .navigationDestination(for: String.self) { s in if s == "dashboard" { DashboardView() } }
            .sheet(isPresented: $showNew) { NewTripSheet() }
            .overlay(alignment: .bottom) {
                if !trips.isEmpty {
                    Text("Stored locally on this device · Private · Offline-first")
                        .font(.caption2).foregroundStyle(.secondary)
                        .padding(.vertical, 8).frame(maxWidth: .infinity).background(.ultraThinMaterial)
                }
            }
        }
    }
}

private struct TripRow: View {
    let trip: Trip
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(trip.status.label).font(.caption2.bold()).padding(.horizontal, 7).padding(.vertical, 3).background(.secondary.opacity(0.18), in: Capsule())
                Spacer()
                if let d = trip.startDate { Text(d, style: .date).font(.caption2).foregroundStyle(.secondary) }
            }
            Text(trip.title).font(.headline).lineLimit(1)
            Label(trip.destination, systemImage: "mappin").font(.caption).foregroundStyle(.secondary)
            if trip.essentialsMissing > 0 { Text("\(trip.essentialsMissing) essentials unpacked").font(.caption2).foregroundStyle(.orange) }
            ProgressView(value: trip.progress).tint(trip.status == .ready ? .green : .accentColor)
            Text("\(trip.items.filter(\.packed).count) of \(trip.items.count) packed · \(Int(trip.progress*100))%").font(.caption2).foregroundStyle(.secondary)
        }.padding(.vertical, 4)
    }
}
