import SwiftUI
import SwiftData

struct TripListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]
    @Binding var selectedTrip: Trip?
    @State private var showNew = false
    @State private var search = ""
    @State private var showDeleteConfirm: Trip?

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
                        Text("Or try a template in More → Templates").font(.caption).foregroundStyle(.secondary)
                    }
                } else if filtered.isEmpty {
                    ContentUnavailableView.search(text: search)
                } else {
                    List {
                        ForEach(filtered) { trip in
                            NavigationLink(value: trip) { TripRow(trip: trip) }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        #if canImport(UIKit)
                                        UINotificationFeedbackGenerator().notificationOccurred(.warning)
                                        #endif
                                        showDeleteConfirm = trip
                                    } label: { Label("Delete", systemImage: "trash") }
                                    .tint(.red)
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        let copy = Trip(title: trip.title + " (Copy)", destination: trip.destination, startDate: trip.startDate, endDate: trip.endDate, purpose: trip.purpose, activities: trip.activities, climateInfo: trip.climateInfo, notes: trip.notes, tripCategory: trip.tripCategory, status: .planning)
                                        context.insert(copy)
                                        for it in trip.items { context.insert(PackingItem(name: it.name, category: it.category, quantity: it.quantity, essential: it.essential, notes: it.notes, photoData: it.photoData, trip: copy)) }
                                        try? context.save()
                                        #if canImport(UIKit)
                                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                                        #endif
                                    } label: { Label("Duplicate", systemImage: "doc.on.doc") }
                                    .tint(.blue)
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .animation(.easeInOut(duration: 0.2), value: filtered.map(\.id))
                    .confirmationDialog("Delete trip?", isPresented: Binding(get: { showDeleteConfirm != nil }, set: { if !$0 { showDeleteConfirm = nil } }), titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            if let t = showDeleteConfirm { context.delete(t); try? context.save() }
                            showDeleteConfirm = nil
                        }
                        Button("Cancel", role: .cancel) { showDeleteConfirm = nil }
                    } message: { Text("This will delete the trip and all its items and outfits. This cannot be undone.") }
                    .navigationDestination(for: Trip.self) { TripDetailView(trip: $0) }
                    .navigationDestination(for: PackingItem.self) { ItemDetailView(item: $0) }
                }
            }
            .navigationTitle("Trips")
            .searchable(text: $search, prompt: "Search trips — destinations, dates, notes")
            .searchActions { if !search.isEmpty { Button("Clear search") { search = "" } } }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showNew = true } label: { Label("New trip", systemImage: "plus") }
                        .accessibilityLabel("Create new trip")
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: "dashboard") { Label("Dashboard", systemImage: "rectangle.grid.2x2") }
                }
            }
            .navigationDestination(for: String.self) { s in if s == "dashboard" { DashboardView() } }
            .sheet(isPresented: $showNew) { NewTripSheet() }
            .overlay(alignment: .bottom) {
                if !trips.isEmpty {
                    Text("Stored locally on this device · Private · Offline-first")
                        .font(.caption2).foregroundStyle(.secondary)
                        .padding(.vertical, 8).frame(maxWidth: .infinity).background(.ultraThinMaterial)
                        .accessibilityHidden(true)
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
                    .accessibilityLabel("Status: \(trip.status.label)")
                Spacer()
                if let d = trip.startDate { Text(d, style: .date).font(.caption2).foregroundStyle(.secondary) }
            }
            Text(trip.title).font(.headline).lineLimit(1)
            Label(trip.destination, systemImage: "mappin").font(.caption).foregroundStyle(.secondary)
            if trip.essentialsMissing > 0 {
                Label("\(trip.essentialsMissing) essentials unpacked", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color(red: 0.72, green: 0.36, blue: 0.0))
                    .accessibilityLabel("\(trip.essentialsMissing) essentials still unpacked")
            }
            ProgressView(value: trip.progress)
                .tint(trip.status == .ready ? .green : .accentColor)
                .accessibilityLabel("Packing progress")
                .accessibilityValue("\(Int(trip.progress * 100)) percent")
            Text("\(trip.items.filter(\.packed).count) of \(trip.items.count) packed · \(Int(trip.progress*100))%")
                .font(.caption2).foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(trip.title), \(trip.destination), \(trip.status.label), \(Int(trip.progress * 100)) percent packed")
    }
}
