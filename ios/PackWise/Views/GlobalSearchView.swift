import SwiftUI
import SwiftData

struct GlobalSearchView: View {
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]
    @Query(sort: \PersonalItem.createdAt, order: .reverse) private var library: [PersonalItem]
    @Query private var templates: [PackTemplate]
    @Query private var outfits: [Outfit]
    @State private var q = ""

    private var lq: String { q.lowercased().trimmingCharacters(in: .whitespaces) }
    private var isSearching: Bool { !lq.isEmpty }

    var body: some View {
        NavigationStack {
            List {
                if !isSearching {
                    Section {
                        Label("Search trips, items, categories, outfits, templates — local only. Everything is on device.", systemImage: "magnifyingglass")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Section("Tips") {
                        Label("Try a destination, item name, or category.", systemImage: "lightbulb").font(.caption).foregroundStyle(.secondary)
                        Label("Search is offline and instant — no network needed.", systemImage: "wifi.slash").font(.caption).foregroundStyle(.secondary)
                    }
                } else {
                    let hits = trips.filter { $0.title.lowercased().contains(lq) || $0.destination.lowercased().contains(lq) }
                    Section("Trips · \(hits.count)") {
                        if hits.isEmpty { Text("No trips matching \"\(q)\"").font(.caption).foregroundStyle(.secondary) }
                        ForEach(hits) { trip in
                            NavigationLink(value: trip) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(trip.title).font(.subheadline)
                                    Text(trip.destination).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    Section("Items · \(filteredItems.count)") {
                        let items = filteredItems
                        if items.isEmpty { Text("No items matching \"\(q)\"").font(.caption).foregroundStyle(.secondary) }
                        ForEach(items) { item in NavigationLink(value: item) { Label(item.name, systemImage: "shippingbox").font(.subheadline) } }
                    }
                    Section("Outfits") {
                        let hits = outfits.filter { $0.name.lowercased().contains(lq) || ($0.dayLabel?.lowercased().contains(lq) ?? false) }
                        if hits.isEmpty { Text("No outfits").font(.caption).foregroundStyle(.secondary) }
                        ForEach(hits) { Text($0.name).font(.subheadline) }
                    }
                    Section("Library") {
                        let hits = library.filter { $0.name.lowercased().contains(lq) }
                        if hits.isEmpty { Text("No library items").font(.caption).foregroundStyle(.secondary) }
                        ForEach(hits) { Text($0.name).font(.subheadline) }
                    }
                    Section("Templates") {
                        let hits = templates.filter { $0.name.lowercased().contains(lq) }
                        if hits.isEmpty { Text("No templates").font(.caption).foregroundStyle(.secondary) }
                        ForEach(hits) { Text($0.name).font(.subheadline) }
                    }
                    if isSearching && hits.isEmpty && filteredItems.isEmpty {
                        Section {
                            ContentUnavailableView.search(text: q)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Search")
            .searchable(text: $q, prompt: "Search everything on device")
            .searchClearAction($q, clearLabel: "Clear")
            .autocorrectionDisabled()
            .navigationDestination(for: Trip.self) { TripDetailView(trip: $0) }
            .navigationDestination(for: PackingItem.self) { ItemDetailView(item: $0) }
        }
    }

    private var filteredItems: [PackingItem] {
        trips.flatMap(\.items).filter { $0.name.lowercased().contains(lq) || $0.category.lowercased().contains(lq) }
    }
}
