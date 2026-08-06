import SwiftUI
import SwiftData

struct GlobalSearchView: View {
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]
    @Query(sort: \PersonalItem.createdAt, order: .reverse) private var library: [PersonalItem]
    @Query private var templates: [PackTemplate]
    @Query private var outfits: [Outfit]
    @State private var q = ""

    var body: some View {
        NavigationStack {
            List {
                if q.isEmpty {
                    Section { Text("Search trips, items, categories, outfits, templates — local only.").font(.caption).foregroundStyle(.secondary) }
                } else {
                    let lq = q.lowercased()
                    Section("Trips") {
                        let hits = trips.filter { $0.title.lowercased().contains(lq) || $0.destination.lowercased().contains(lq) }
                        if hits.isEmpty { Text("No trips").font(.caption).foregroundStyle(.secondary) }
                        ForEach(hits) { NavigationLink(value: $0) { Text($0.title) } }
                    }
                    Section("Items") {
                        let items = trips.flatMap(\.items).filter { $0.name.lowercased().contains(lq) || $0.category.lowercased().contains(lq) }
                        if items.isEmpty { Text("No items").font(.caption).foregroundStyle(.secondary) }
                        ForEach(items) { NavigationLink(value: $0) { Label($0.name, systemImage: "shippingbox") } }
                    }
                    Section("Outfits") {
                        let hits = outfits.filter { $0.name.lowercased().contains(lq) || ($0.dayLabel?.lowercased().contains(lq) ?? false) }
                        if hits.isEmpty { Text("No outfits").font(.caption).foregroundStyle(.secondary) }
                        ForEach(hits) { Text($0.name) }
                    }
                    Section("Library") {
                        let hits = library.filter { $0.name.lowercased().contains(lq) }
                        if hits.isEmpty { Text("No library items").font(.caption).foregroundStyle(.secondary) }
                        ForEach(hits) { Text($0.name) }
                    }
                    Section("Templates") {
                        let hits = templates.filter { $0.name.lowercased().contains(lq) }
                        if hits.isEmpty { Text("No templates").font(.caption).foregroundStyle(.secondary) }
                        ForEach(hits) { Text($0.name) }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Search")
            .searchable(text: $q, prompt: "Search everything on device")
            .navigationDestination(for: Trip.self) { TripDetailView(trip: $0) }
            .navigationDestination(for: PackingItem.self) { ItemDetailView(item: $0) }
        }
    }
}
