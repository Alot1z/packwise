import SwiftUI
import SwiftData
import CoreLocation

struct TripDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var trip: Trip
    @State private var tab: Tab = .items
    @State private var search = ""
    @State private var filterCategory = "All"
    @State private var filterPacked: PackedFilter = .all
    @State private var essentialsOnly = false
    @State private var newName = ""
    @State private var newCategory = "General"
    @State private var newQty = 1
    @State private var newEssential = false
    @State private var newNotes = ""
    @State private var canvasIDs: [UUID] = []
    @State private var outfitName = ""
    @State private var outfitDay = ""
    @State private var showDeleteConfirm = false
    @State private var weather: WeatherSnapshot?
    @State private var weatherChecked = false

    enum Tab: String, CaseIterable { case items = "Packing List", outfits = "Outfits", export = "Export" }
    enum PackedFilter: String, CaseIterable { case all = "All", packed = "Packed", unpacked = "Unpacked" }

    var filtered: [PackingItem] {
        var list = Array(trip.items)
        if !search.isEmpty {
            let q = search.lowercased()
            list = list.filter { $0.name.lowercased().contains(q) || $0.category.lowercased().contains(q) || ($0.notes?.lowercased().contains(q) ?? false) }
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
    var grouped: [String: [PackingItem]] { Dictionary(grouping: filtered, by: \.category) }

    var body: some View {
        VStack(spacing: 0) {
            header
            Picker("Section", selection: $tab) {
                ForEach(Tab.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }.pickerStyle(.segmented).padding(.horizontal).padding(.vertical, 8)
            TabView(selection: $tab) {
                itemsTab.tag(Tab.items)
                outfitsTab.tag(Tab.outfits)
                exportTab.tag(Tab.export)
            }.tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(trip.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(TripStatus.allCases) { s in
                        Button(s.label) {
                            trip.status = s; trip.updatedAt = Date(); try? context.save()
                            #if canImport(UIKit)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                        }
                    }
                    Divider()
                    Button("Duplicate trip", systemImage: "doc.on.doc") { duplicate() }
                    Button("Delete trip", systemImage: "trash", role: .destructive) { showDeleteConfirm = true }
                } label: { Label("Options", systemImage: "ellipsis.circle") }
            }
        }
        .searchable(text: $search, prompt: "Search items, categories, notes")
        .task { await loadWeatherIfPossible() }
        .confirmationDialog("Delete trip?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteTrip() }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This will delete the trip and all its items and outfits. This cannot be undone.") }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(trip.status.label).font(.caption2.bold()).padding(.horizontal, 8).padding(.vertical, 4).background(.secondary.opacity(0.18), in: Capsule())
                    .accessibilityLabel("Status \(trip.status.label)")
                if let p = trip.purpose { Text(p).font(.caption).foregroundStyle(.secondary).lineLimit(1) }
                Spacer()
                Text("\(Int(trip.progress*100))%")
                    .font(.title3.bold().monospacedDigit())
                    .accessibilityLabel("\(Int(trip.progress * 100)) percent packed")
                    .contentTransition(.numericText())
            }
            Label(trip.destination, systemImage: "mappin").font(.subheadline).foregroundStyle(.secondary)
            if let s = trip.startDate, let e = trip.endDate {
                Label("\(s.formatted(date: .abbreviated, time: .omitted)) — \(e.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar").font(.caption).foregroundStyle(.secondary)
            }
            if let a = trip.activities, !a.isEmpty { Label(a, systemImage: "figure.hiking").font(.caption).foregroundStyle(.secondary) }
            if let c = trip.climateInfo, !c.isEmpty { Label(c, systemImage: "cloud.sun").font(.caption).foregroundStyle(.secondary) }
            if let weather {
                Label("\(weather.condition) · \(Int(weather.temperatureC))°C now", systemImage: weather.symbolName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Weather: \(weather.condition), \(Int(weather.temperatureC)) degrees Celsius")
                if let first = weather.daily.first {
                    Text("Trip days: high \(Int(first.highC))° · low \(Int(first.lowC))° · \(Int((first.precipitationChance) * 100))% rain")
                        .font(.caption2).foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
            }
            if trip.essentialsMissing > 0 {
                Label("\(trip.essentialsMissing) essentials still unpacked", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color(red: 0.72, green: 0.36, blue: 0.0))
            }

            // Local recommendations (text-based always; weather-aware when available)
            let recs = RecommendationService.suggestions(for: trip, weather: weather)
            if !recs.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Suggested — confirm to add").font(.caption2.bold())
                    ForEach(recs.prefix(3)) { r in
                        Button {
                            let item = PackingItem(name: r.title, category: r.category, trip: trip)
                            context.insert(item); trip.updatedAt = Date(); try? context.save()
                            #if canImport(UIKit)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            #endif
                        } label: {
                            HStack { Text(r.title).font(.caption); Text(r.reason).font(.caption2).foregroundStyle(.secondary); Spacer(); Image(systemName: "plus.circle").accessibilityHidden(true) }
                        }
                        .accessibilityLabel("Add \(r.title) — \(r.reason)")
                    }
                }.padding(8).background(.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            }

            ProgressView(value: trip.progress).tint(trip.status == .ready ? .green : .accentColor)
                .accessibilityLabel("Packing progress")
                .accessibilityValue("\(Int(trip.progress * 100)) percent")
            Text("\(trip.items.filter(\.packed).count) of \(trip.items.count) packed").font(.caption2).foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }

    private var itemsTab: some View {
        List {
            Section {
                Picker("Category", selection: $filterCategory) {
                    Text("All").tag("All")
                    ForEach(builtInCategoryNames, id: \.self) { Text($0).tag($0) }
                }
                Picker("Status", selection: $filterPacked) { ForEach(PackedFilter.allCases, id: \.self) { Text($0.rawValue).tag($0) } }.pickerStyle(.segmented)
                Toggle("Essentials only", isOn: $essentialsOnly)
            }
            Section("Add item") {
                TextField("Item name", text: $newName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                Picker("Category", selection: $newCategory) { ForEach(builtInCategoryNames, id: \.self) { Text($0).tag($0) } }
                Stepper("Quantity: \(newQty)", value: $newQty, in: 1...50)
                TextField("Notes", text: $newNotes)
                Toggle("Essential", isOn: $newEssential)
                Button("Add") {
                    let item = PackingItem(name: newName.trimmingCharacters(in: .whitespaces), category: newCategory, quantity: newQty, essential: newEssential, notes: newNotes.isEmpty ? nil : newNotes, trip: trip)
                    context.insert(item); trip.updatedAt = Date(); try? context.save()
                    #if canImport(UIKit)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    #endif
                    newName = ""; newNotes = ""; newEssential = false; newQty = 1
                }.disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            if grouped.isEmpty {
                Section { Text("No items match. Adjust search or add a new item.").font(.caption).foregroundStyle(.secondary) }
            } else {
                ForEach(grouped.keys.sorted(), id: \.self) { cat in
                    Section("\(cat) · \(grouped[cat]!.count)") {
                        ForEach(grouped[cat]!) { item in
                            NavigationLink(value: item) {
                                ItemRowInline(item: item) {
                                    item.packed.toggle(); trip.updatedAt = Date(); try? context.save()
                                    #if canImport(UIKit)
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    #endif
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    context.delete(item); try? context.save()
                                } label: { Label("Delete", systemImage: "trash") }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    item.packed.toggle(); trip.updatedAt = Date(); try? context.save()
                                } label: { Label(item.packed ? "Unpack" : "Pack", systemImage: item.packed ? "circle" : "checkmark.circle.fill") }
                                .tint(item.packed ? .gray : .green)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: PackingItem.self) { ItemDetailView(item: $0) }
    }

    private var outfitsTab: some View {
        List {
            Section {
                TextField("Outfit name — e.g. Arrival", text: $outfitName)
                    .autocorrectionDisabled()
                TextField("Day — Monday or Day 2", text: $outfitDay)
                if trip.items.isEmpty {
                    Text("Add items first, then compose outfits.").font(.caption).foregroundStyle(.secondary)
                } else {
                    // Palette: tap to add, or drag a chip onto the canvas below.
                    Text("Tap an item to add it, or drag it onto the canvas.").font(.caption).foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(trip.items.sorted(by: { $0.name < $1.name })) { item in
                                OutfitItemChip(item: item, isSelected: canvasIDs.contains(item.id))
                                    .draggable(item.id.uuidString)
                                    .onTapGesture {
                                        toggleCanvas(item.id)
                                    }
                                    .accessibilityAddTraits(canvasIDs.contains(item.id) ? .isSelected : [])
                                    .accessibilityLabel("\(item.name) — \(canvasIDs.contains(item.id) ? "on canvas" : "not on canvas")")
                                    .accessibilityHint("Double-tap to add or remove from the outfit")
                            }
                        }.padding(.vertical, 4)
                    }
                    // Canvas: drag to reorder, drop to insert, x to remove.
                    if canvasIDs.isEmpty {
                        Text("No items on the canvas yet.").font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(canvasIDs, id: \.self) { id in
                                    if let item = trip.items.first(where: { $0.id == id }) {
                                        OutfitCanvasChip(item: item) {
                                            removeFromCanvas(id)
                                        }
                                        .draggable(id.uuidString)
                                        .dropDestination(for: String.self) { dropped, _ in
                                            guard let first = dropped.first, let uuid = UUID(uuidString: first) else { return }
                                            canvasIDs = OutfitComposer.moving(uuid, before: id, in: canvasIDs)
                                        }
                                    }
                                }
                            }.padding(.vertical, 4)
                        }
                    }
                }
                Button("Save outfit") {
                    let o = Outfit(name: outfitName.trimmingCharacters(in: .whitespaces), dayLabel: outfitDay.isEmpty ? nil : outfitDay, itemIDs: canvasIDs, trip: trip)
                    context.insert(o); trip.updatedAt = Date(); try? context.save()
                    #if canImport(UIKit)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    #endif
                    outfitName = ""; outfitDay = ""; canvasIDs = []
                }.disabled(outfitName.trimmingCharacters(in: .whitespaces).isEmpty || canvasIDs.isEmpty)
            } header: {
                Text("Compose outfit")
            }
            if trip.outfits.isEmpty {
                Section { Text("No outfits yet. Compose one from your packing list.").font(.caption).foregroundStyle(.secondary) }
            } else {
                ForEach(trip.outfits.sorted { ($0.isFavorite ? 0 : 1, $0.createdAt) < ($1.isFavorite ? 0 : 1, $1.createdAt) }) { outfit in
                    NavigationLink(value: outfit) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                if outfit.isFavorite { Image(systemName: "star.fill").foregroundStyle(.yellow).font(.caption2).accessibilityLabel("Favorite") }
                                Text(outfit.name).font(.subheadline.weight(.medium))
                            }
                            if let d = outfit.dayLabel { Text(d).font(.caption).foregroundStyle(.secondary) }
                            Text(outfit.itemIDs.compactMap { id in trip.items.first(where: { $0.id == id })?.name }.joined(separator: " · ")).font(.caption2).foregroundStyle(.secondary).lineLimit(2)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            outfit.isFavorite.toggle(); trip.updatedAt = Date(); try? context.save()
                            #if canImport(UIKit)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                        } label: { Label(outfit.isFavorite ? "Unfavorite" : "Favorite", systemImage: outfit.isFavorite ? "star.slash" : "star.fill") }
                        .tint(.yellow)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) { context.delete(outfit); try? context.save() } label: { Label("Delete", systemImage: "trash") }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: Outfit.self) { OutfitDetailView(outfit: $0, trip: trip) }
    }

    private func toggleCanvas(_ id: UUID) {
        if canvasIDs.contains(id) {
            canvasIDs = OutfitComposer.removing(id, from: canvasIDs)
        } else {
            canvasIDs = OutfitComposer.adding(id, to: canvasIDs)
        }
        #if canImport(UIKit)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }

    private func removeFromCanvas(_ id: UUID) {
        canvasIDs = OutfitComposer.removing(id, from: canvasIDs)
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    private var exportTab: some View {
        List {
            Section("Local data") { Text("All data is on device and portable via JSON export. No cloud required.").font(.caption).foregroundStyle(.secondary) }
            Section {
                ShareLink(item: exportURL(), preview: SharePreview("PackWise — \(trip.title)")) { Label("Share file", systemImage: "square.and.arrow.up") }
                Button { UIPasteboard.general.string = exportString() } label: { Label("Copy JSON", systemImage: "doc.on.doc") }
            }
            Section("Quick stats") {
                LabeledContent("Items", value: "\(trip.items.count)")
                LabeledContent("Packed", value: "\(trip.items.filter(\.packed).count)")
                LabeledContent("Essentials missing", value: "\(trip.essentialsMissing)")
                LabeledContent("Outfits", value: "\(trip.outfits.count)")
            }
        }.listStyle(.insetGrouped)
    }

    /// Fetches live weather once when the trip has a destination coordinate.
    /// Fails silently to the deterministic text engine (unsigned builds have no
    /// WeatherKit entitlement — that is the designed fallback, not an error).
    @MainActor
    private func loadWeatherIfPossible() async {
        guard !weatherChecked,
              let lat = trip.destinationLatitude,
              let lon = trip.destinationLongitude else { return }
        weatherChecked = true
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        weather = await WeatherProvider.snapshot(for: coord)
    }

    private func exportString() -> String {
        let payload: [String: Any] = ["trip": ["title": trip.title, "destination": trip.destination, "status": trip.status.rawValue], "items": trip.items.map { ["name": $0.name, "category": $0.category, "quantity": $0.quantity, "packed": $0.packed] }, "outfits": trip.outfits.map { ["name": $0.name, "day": $0.dayLabel ?? ""] }]
        if let d = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted), let s = String(data: d, encoding: .utf8) { return s }
        return "{}"
    }
    private func exportURL() -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(trip.title)-packwise.json")
        try? exportString().write(to: url, atomically: true, encoding: .utf8)
        return url
    }
    private func duplicate() {
        let copy = Trip(title: trip.title + " (Copy)", destination: trip.destination, startDate: trip.startDate, endDate: trip.endDate, purpose: trip.purpose, activities: trip.activities, climateInfo: trip.climateInfo, notes: trip.notes, tripCategory: trip.tripCategory, status: .planning)
        context.insert(copy)
        for it in trip.items { context.insert(PackingItem(name: it.name, category: it.category, quantity: it.quantity, essential: it.essential, notes: it.notes, photoData: it.photoData, trip: copy)) }
        try? context.save()
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }
    private func deleteTrip() { context.delete(trip); try? context.save() }
}

private struct ItemRowInline: View {
    @Bindable var item: PackingItem
    var onToggle: () -> Void
    var body: some View {
        HStack(spacing: 10) {
            Button(action: onToggle) {
                Image(systemName: item.packed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.packed ? .green : .secondary)
                    .accessibilityHidden(true)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.packed ? "Mark \(item.name) as unpacked" : "Mark \(item.name) as packed")
            .accessibilityValue(item.packed ? "Packed" : "Unpacked")
            .accessibilityHint("Double-tap to toggle")
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).strikethrough(item.packed).font(.subheadline)
                if let n = item.notes, !n.isEmpty { Text(n).font(.caption).foregroundStyle(.secondary).lineLimit(1) }
                Text("×\(item.quantity) · \(item.category)").font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            if item.essential { Image(systemName: "star.fill").foregroundStyle(Color(red: 0.68, green: 0.52, blue: 0.0)).font(.caption2).accessibilityLabel("Essential") }
        }.opacity(item.packed ? 0.6 : 1)
        .contentShape(Rectangle())
    }
}

/// A tappable item chip for the palette (also serves as a drag source).
private struct OutfitItemChip: View {
    let item: PackingItem
    let isSelected: Bool
    var body: some View {
        VStack(spacing: 4) {
            thumbnail
            Text(item.name).font(.caption2).lineLimit(1).foregroundStyle(.primary)
        }
        .frame(width: 64)
        .padding(6)
        .background(isSelected ? Color.accentColor.opacity(0.25) : Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 1))
        .contentShape(RoundedRectangle(cornerRadius: 10))
    }
    @ViewBuilder private var thumbnail: some View {
        if let data = item.photoData, let ui = UIImage(data: data) {
            Image(uiImage: ui).resizable().scaledToFill().frame(width: 44, height: 44).clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Image(systemName: "tshirt").font(.title2).foregroundStyle(.secondary).frame(width: 44, height: 44).background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

/// A chip on the outfit canvas: drag to reorder, drop to insert before, x to remove.
private struct OutfitCanvasChip: View {
    let item: PackingItem
    let onRemove: () -> Void
    var body: some View {
        VStack(spacing: 4) {
            thumbnail
            Text(item.name).font(.caption2).lineLimit(1).foregroundStyle(.primary)
        }
        .frame(width: 64)
        .padding(6)
        .background(Color.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .topTrailing) {
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill").font(.caption).foregroundStyle(.secondary).background(Circle().fill(Color(.systemBackground)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(item.name)")
            .offset(x: 8, y: -8)
        }
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityLabel("\(item.name) on canvas")
        .accessibilityHint("Drag to reorder, double-tap the x to remove")
    }
    @ViewBuilder private var thumbnail: some View {
        if let data = item.photoData, let ui = UIImage(data: data) {
            Image(uiImage: ui).resizable().scaledToFill().frame(width: 44, height: 44).clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Image(systemName: "tshirt").font(.title2).foregroundStyle(.secondary).frame(width: 44, height: 44).background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

private struct OutfitDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var outfit: Outfit
    let trip: Trip
    var body: some View {
        Form {
            TextField("Name", text: $outfit.name).onChange(of: outfit.name) { _, _ in try? context.save() }
            TextField("Day label", text: Binding(get: { outfit.dayLabel ?? "" }, set: { outfit.dayLabel = $0.isEmpty ? nil : $0 })).onChange(of: outfit.dayLabel ?? "") { _, _ in try? context.save() }
            Section("Items") {
                if outfit.itemIDs.isEmpty {
                    Text("No items in this outfit.").font(.caption).foregroundStyle(.secondary)
                } else {
                    ForEach(outfit.itemIDs, id: \.self) { id in
                        if let it = trip.items.first(where: { $0.id == id }) {
                            HStack(spacing: 10) {
                                if let data = it.photoData, let ui = UIImage(data: data) {
                                    Image(uiImage: ui).resizable().scaledToFill().frame(width: 32, height: 32).clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                Label(it.name, systemImage: it.packed ? "checkmark.circle.fill" : "circle")
                            }
                        } else { Text("Missing item").foregroundStyle(.secondary) }
                    }
                }
            }
            Section("Note") { TextEditor(text: Binding(get: { outfit.note ?? "" }, set: { outfit.note = $0.isEmpty ? nil : $0 })).frame(minHeight: 60).accessibilityLabel("Note") }
        }
        .navigationTitle("Outfit").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    outfit.isFavorite.toggle(); try? context.save()
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                } label: {
                    Image(systemName: outfit.isFavorite ? "star.fill" : "star")
                }
                .accessibilityLabel(outfit.isFavorite ? "Remove from favorites" : "Add to favorites")
                .accessibilityValue(outfit.isFavorite ? "Favorite" : "Not favorite")
            }
        }
    }
}
