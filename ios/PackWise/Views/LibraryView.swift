import SwiftUI
import SwiftData
import PhotosUI

struct LibraryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \PersonalItem.createdAt, order: .reverse) private var library: [PersonalItem]
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]
    @State private var search = ""
    @State private var showAdd = false
    @State private var categoryFilter = "All"
    @State private var addToTripID: UUID?

    var filtered: [PersonalItem] {
        var list = library
        if categoryFilter != "All" { list = list.filter { $0.category == categoryFilter } }
        if !search.isEmpty {
            let q = search.lowercased()
            list = list.filter { $0.name.lowercased().contains(q) }
        }
        return list
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Category", selection: $categoryFilter) {
                        Text("All").tag("All")
                        ForEach(builtInCategoryNames, id: \.self) { Text($0).tag($0) }
                    }.pickerStyle(.segmented)
                }
                if filtered.isEmpty {
                    Section { Text("No items yet. Add personal items with photos and reuse them across trips.").font(.caption).foregroundStyle(.secondary) }
                }
                ForEach(filtered) { item in
                    NavigationLink(value: item) {
                        HStack(spacing: 10) {
                            if let d = item.photoData, let ui = UIImage(data: d) {
                                Image(uiImage: ui).resizable().scaledToFill().frame(width: 44, height: 44).clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                RoundedRectangle(cornerRadius: 8).fill(.secondary.opacity(0.15)).frame(width: 44, height: 44).overlay(Image(systemName: "shippingbox"))
                            }
                            VStack(alignment: .leading) {
                                Text(item.name).font(.subheadline.weight(.medium))
                                Text(item.category).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if item.isFavorite { Image(systemName: "star.fill").foregroundStyle(.yellow).font(.caption) }
                        }
                    }
                }
                if !filtered.isEmpty {
                    Section("Reuse") {
                        Picker("Add selected library items to trip", selection: $addToTripID) {
                            Text("Choose trip").tag(nil as UUID?)
                            ForEach(trips) { Text($0.title).tag($0.id as UUID?) }
                        }
                        Text("Open an item to edit, then use Duplicate → choose destination trip.").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Library")
            .searchable(text: $search, prompt: "Search library")
            .toolbar { Button { showAdd = true } label: { Label("Add", systemImage: "plus") } }
            .sheet(isPresented: $showAdd) { AddPersonalItemSheet() }
            .navigationDestination(for: PersonalItem.self) { PersonalItemDetail(item: $0) }
        }
    }
}

private struct AddPersonalItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var name = ""
    @State private var category = "General"
    @State private var notes = ""
    @State private var fav = false
    @State private var picker: PhotosPickerItem?
    @State private var data: Data?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Picker("Category", selection: $category) { ForEach(builtInCategoryNames, id: \.self) { Text($0).tag($0) } }
                TextField("Notes", text: $notes)
                Toggle("Favorite", isOn: $fav)
                PhotosPicker(selection: $picker, matching: .images) { Label("Add photo", systemImage: "photo") }
                if let d = data, let ui = UIImage(data: d) { Image(uiImage: ui).resizable().scaledToFit().frame(maxHeight: 180).clipShape(RoundedRectangle(cornerRadius: 12)) }
            }
            .navigationTitle("New Library Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let item = PersonalItem(name: name.trimmingCharacters(in: .whitespaces), category: category, notes: notes.isEmpty ? nil : notes, photoData: data, isFavorite: fav)
                        context.insert(item); try? context.save(); dismiss()
                    }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: picker) { _, v in Task { if let d = try? await v?.loadTransferable(type: Data.self) { data = d } } }
        }
    }
}

private struct PersonalItemDetail: View {
    @Environment(\.modelContext) private var context
    @Bindable var item: PersonalItem
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]
    @State private var targetTrip: UUID?
    @State private var picker: PhotosPickerItem?

    var body: some View {
        Form {
            Section("Photo") {
                if let d = item.photoData, let ui = UIImage(data: d) { Image(uiImage: ui).resizable().scaledToFit().frame(maxHeight: 200).clipShape(RoundedRectangle(cornerRadius: 12)) }
                PhotosPicker(selection: $picker, matching: .images) { Label("Change photo", systemImage: "photo") }
            }
            Section {
                TextField("Name", text: $item.name)
                Picker("Category", selection: $item.category) { ForEach(builtInCategoryNames, id: \.self) { Text($0).tag($0) } }
                TextField("Notes", text: Binding(get: { item.notes ?? "" }, set: { item.notes = $0.isEmpty ? nil : $0 }))
                Toggle("Favorite", isOn: $item.isFavorite)
            }
            Section("Reuse in trip") {
                Picker("Trip", selection: $targetTrip) { Text("Choose trip").tag(nil as UUID?); ForEach(trips) { Text($0.title).tag($0.id as UUID?) } }
                Button("Add copy to trip") {
                    guard let id = targetTrip, let trip = trips.first(where: { $0.id == id }) else { return }
                    let copy = PackingItem(name: item.name, category: item.category, notes: item.notes, photoData: item.photoData, personalItemID: item.id, trip: trip)
                    context.insert(copy); trip.updatedAt = Date(); try? context.save()
                }.disabled(targetTrip == nil)
            }
        }
        .navigationTitle("Library Item")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: picker) { _, v in Task { if let d = try? await v?.loadTransferable(type: Data.self) { item.photoData = d; try? context.save() } } }
        .onChange(of: item.name) { _, _ in try? context.save() }
    }
}
