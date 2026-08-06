import SwiftUI
import SwiftData
import PhotosUI

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var item: PackingItem
    @State private var pickerItem: PhotosPickerItem?
    @State private var draftNotes: String = ""
    @State private var draftQty: Int = 1

    var body: some View {
        Form {
            Section {
                if let data = item.photoData, let ui = UIImage(data: data) {
                    Image(uiImage: ui).resizable().scaledToFit().frame(maxHeight: 220).clipShape(RoundedRectangle(cornerRadius: 12))
                    Button("Remove photo", role: .destructive) { item.photoData = nil; try? context.save() }
                }
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label(item.photoData == nil ? "Add photo" : "Change photo", systemImage: "photo")
                }
            }

            Section("Item") {
                TextField("Name", text: $item.name)
                Picker("Category", selection: $item.category) { ForEach(builtInCategoryNames, id: \.self) { Text($0).tag($0) } }
                Stepper("Quantity: \(item.quantity)", value: $item.quantity, in: 1...99)
                Toggle("Packed", isOn: $item.packed)
                Toggle("Essential", isOn: $item.essential)
                Toggle("Favorite", isOn: $item.isFavorite)
            }

            Section("Notes") {
                TextEditor(text: Binding(get: { item.notes ?? "" }, set: { item.notes = $0.isEmpty ? nil : $0 }))
                    .frame(minHeight: 80)
            }

            Section {
                Text("Stored locally on device. Changes save automatically.").font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Item Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: pickerItem) { _, new in
            Task {
                if let data = try? await new?.loadTransferable(type: Data.self) {
                    // Basic downscale to keep local storage reasonable
                    if let img = UIImage(data: data), let jpeg = img.jpegData(compressionQuality: 0.7) {
                        item.photoData = jpeg
                        try? context.save()
                    } else {
                        item.photoData = data
                        try? context.save()
                    }
                }
            }
        }
        .onChange(of: item.name) { _, _ in try? context.save() }
        .onChange(of: item.category) { _, _ in try? context.save() }
        .onChange(of: item.quantity) { _, _ in try? context.save() }
        .onChange(of: item.packed) { _, _ in try? context.save() }
    }
}
