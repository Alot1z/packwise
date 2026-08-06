import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var trip: Trip
    @State private var tab: Tab = .items
    @State private var itemSearch = ""
    @State private var filterCategory = "All"
    @State private var filterPacked: PackedFilter = .all
    @State private var essentialsOnly = false
    @State private var newName = ""
    @State private var newCategory = "General"
    @State private var newQty = 1
    @State private var newEssential = false
    @State private var newNotes = ""
    @State private var selectedIDs: Set<UUID> = []
    @State private var outfitName = ""
    @State private var outfitDay = ""

    enum Tab: String, CaseIterable { case items = "Packing List", outfits = "Outfit Planner", export = "Export" }
    enum PackedFilter: String, CaseIterable { case all = "All", packed = "Packed", unpacked = "Unpacked" }

    var filtered: [PackingItem] {
        var list = Array(trip.items)
        if !itemSearch.isEmpty {
            let q = itemSearch.lowercased()
            list = list.filter { $0.name.lowercased().contains(q) || $0.category.lowercased().contains(q) }
        }
        if filterCategory != "All" { list = list.filter { $0.category == filterCategory } }
        switch filterPacked {
        case .packed: list = list.filter(\.packed)
        case .unpacked: list = list.filter { !$0.packed }
        case .all: break
        }
        if essentialsOnly { list = list.filter(\.essential) }
        return list.sorted { $0.createdAt < $1.createdAt }
    }

    var grouped: [String: [PackingItem]] {
        Dictionary(grouping: filtered, by: \.category)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Picker("Tab", selection: $tab) {
                ForEach(Tab.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding()

            TabView(selection: $tab) {
                itemsTab.tag(Tab.items)
                outfitsTab.tag(Tab.outfits)
                exportTab.tag(Tab.export)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(trip.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(TripStatus.allCases) { s in
                        Button(s.label) { trip.status = s; trip.updatedAt = Date(); try? context.save() }
                    }
                    Divider()
                    Button("Duplicate trip", systemImage: "doc.on.doc") { duplicate() }
                    Button("Delete trip", systemImage: "trash", role: .destructive) { deleteTrip() }
                } label: { Label("Options", systemImage: "ellipsis.circle") }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(trip.status.label).font(.caption2.bold()).padding(.horizontal, 8).padding(.vertical, 4).background(.secondary.opacity(0.18), in: Capsule())
                if let p = trip.purpose { Text(p).font(.caption).foregroundStyle(.secondary) }
                Spacer()
                Text("\(Int(trip.progress*100))%").font(.title3.bold())
            }
            Label(trip.destination, systemImage: "mappin").font(.subheadline).foregroundStyle(.secondary)
            if let s = trip.startDate, let e = trip.endDate {
                Label("\(s.formatted(date: .abbreviated, time: .omitted)) — \(e.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar").font(.caption).foregroundStyle(.secondary)
            }
            ProgressView(value: trip.progress).tint(trip.status == .ready ? .green : .accentColor)
            Text("\(trip.items.filter(\.packed).count) of \(trip.items.count) packed").font(.caption2).foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }

    private var itemsTab: some View {
        List {
            Section {
                HStack {
                    TextField("Search", text: $itemSearch)
                    Picker("Category", selection: $filterCategory) {
                        Text("All").tag("All")
                        ForEach(defaultCategories, id: \.self) { Text($0).tag($0) }
                    }.labelsHidden().pickerStyle(.menu)
                }
                Picker("Status", selection: $filterPacked) {
                    ForEach(PackedFilter.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                Toggle("Essentials only", isOn: $essentialsOnly)
            }

            Section("Add to packing list") {
                TextField("Item name", text: $newName)
                Picker("Category", selection: $newCategory) { ForEach(defaultCategories, id: \.self) { Text($0).tag($0) } }
                Stepper("Quantity: \(newQty)", value: $newQty, in: 1...50)
                TextField("Notes — material, colour, reminders", text: $newNotes)
                Toggle("Essential", isOn: $newEssential)
                Button("Add") {
                    let item = PackingItem(name: newName.trimmingCharacters(in: .whitespaces), category: newCategory, quantity: newQty, essential: newEssential, notes: newNotes.isEmpty ? nil : newNotes, trip: trip)
                    context.insert(item)
                    trip.updatedAt = Date()
                    try? context.save()
                    newName = ""; newNotes = ""; newEssential = false; newQty = 1
                }.disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if grouped.isEmpty {
                Section { Text("No items match the current filters. Adjust your search or add a new item.").font(.caption).foregroundStyle(.secondary) }
            } else {
                ForEach(grouped.keys.sorted(), id: \.self) { cat in
                    Section("\(cat) · \(grouped[cat]!.count)") {
                        ForEach(grouped[cat]!) { item in
                            ItemRow(item: item) {
                                item.packed.toggle()
                                trip.updatedAt = Date()
                                try? context.save()
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var outfitsTab: some View {
        List {
            Section("Compose outfit") {
                TextField("Outfit name — for example, Arrival", text: $outfitName)
                TextField("Day — Monday or Day 2", text: $outfitDay)
                if trip.items.isEmpty {
                    Text("Add items first, then compose outfits.").font(.caption).foregroundStyle(.secondary)
                } else {
                    ForEach(trip.items.sorted(by: { $0.name < $1.name })) { item in
                        Button {
                            if selectedIDs.contains(item.id) { selectedIDs.remove(item.id) } else { selectedIDs.insert(item.id) }
                        } label: {
                            HStack {
                                Text(item.name).foregroundStyle(.primary)
                                Spacer()
                                if selectedIDs.contains(item.id) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.accentColor) }
                            }
                        }
                    }
                }
                Button("Save outfit") {
                    let o = Outfit(name: outfitName.trimmingCharacters(in: .whitespaces), dayLabel: outfitDay.isEmpty ? nil : outfitDay, itemIDs: Array(selectedIDs), trip: trip)
                    context.insert(o)
                    trip.updatedAt = Date()
                    try? context.save()
                    outfitName = ""; outfitDay = ""; selectedIDs = []
                }.disabled(outfitName.trimmingCharacters(in: .whitespaces).isEmpty || selectedIDs.isEmpty)
            }

            if trip.outfits.isEmpty {
                Section { Text("No outfits yet. Compose one from your packing list above.").font(.caption).foregroundStyle(.secondary) }
            } else {
                ForEach(trip.outfits) { outfit in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(outfit.name).font(.headline)
                        if let d = outfit.dayLabel { Text(d).font(.caption).foregroundStyle(.secondary) }
                        WrappingChips(ids: outfit.itemIDs, items: trip.items)
                    }
                    .swipeActions { Button("Delete", role: .destructive) { context.delete(outfit); try? context.save() } }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var exportTab: some View {
        List {
            Section("Local data ownership") {
                Text("PackWise keeps your trips, lists, photos, and preferences on device. Export a portable file whenever you need to move or back up your data. No cloud dependency for the core experience.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section {
                ShareLink(item: exportData(), preview: SharePreview("PackWise — \(trip.title)")) {
                    Label("Share file", systemImage: "square.and.arrow.up")
                }
                Button { UIPasteboard.general.string = exportString() } label: { Label("Copy JSON", systemImage: "doc.on.doc") }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func exportString() -> String {
        let payload: [String: Any] = [
            "trip": ["title": trip.title, "destination": trip.destination, "status": trip.status.rawValue],
            "items": trip.items.map { ["name": $0.name, "category": $0.category, "quantity": $0.quantity, "packed": $0.packed] },
            "outfits": trip.outfits.map { ["name": $0.name, "day": $0.dayLabel ?? ""] }
        ]
        if let d = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted), let s = String(data: d, encoding: .utf8) { return s }
        return "{}"
    }
    private func exportData() -> String {
        let s = exportString()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(trip.title)-packwise.json")
        try? s.write(to: url, atomically: true, encoding: .utf8)
        return s
    }
    private func duplicate() {
        let copy = Trip(title: trip.title + " (Copy)", destination: trip.destination, startDate: trip.startDate, endDate: trip.endDate, purpose: trip.purpose, status: .planning)
        context.insert(copy)
        for it in trip.items {
            let n = PackingItem(name: it.name, category: it.category, quantity: it.quantity, essential: it.essential, notes: it.notes, trip: copy)
            context.insert(n)
        }
        try? context.save()
    }
    private func deleteTrip() {
        context.delete(trip)
        try? context.save()
    }
}

private struct ItemRow: View {
    @Bindable var item: PackingItem
    var onToggle: () -> Void
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.packed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.packed ? .green : .secondary)
            }.buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).strikethrough(item.packed).font(.subheadline)
                if let n = item.notes, !n.isEmpty { Text(n).font(.caption).foregroundStyle(.secondary).lineLimit(1) }
                Text("Tap to view detail · ×\(item.quantity)").font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            if item.essential { Image(systemName: "star.fill").foregroundStyle(.yellow).font(.caption2) }
            Text(item.category).font(.caption2).padding(.horizontal, 6).padding(.vertical, 2).background(.secondary.opacity(0.15), in: Capsule())
        }
        .opacity(item.packed ? 0.6 : 1)
        .swipeActions {
            Button("Delete", role: .destructive) {
                if let ctx = item.modelContext { ctx.delete(item); try? ctx.save() }
            }
        }
    }
}

private struct WrappingChips: View {
    let ids: [UUID]
    let items: [PackingItem]
    var body: some View {
        FlexibleWrap(data: ids) { id in
            let name = items.first(where: { $0.id == id })?.name ?? "Item"
            return Text(name).font(.caption2).padding(.horizontal, 8).padding(.vertical, 4).background(.secondary.opacity(0.16), in: Capsule())
        }
    }
}

private struct FlexibleWrap<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let content: (Data.Element) -> Content
    var body: some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        return GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(Array(data), id: \.self) { el in
                    content(el)
                        .alignmentGuide(.leading) { d in
                            if abs(width - d.width) > geo.size.width {
                                width = 0; height -= d.height + 6
                            }
                            let r = width
                            if el == data.last { width = 0 } else { width -= d.width + 6 }
                            return r
                        }
                        .alignmentGuide(.top) { _ in height }
                }
            }
        }
        .frame(height: 44)
    }
}
