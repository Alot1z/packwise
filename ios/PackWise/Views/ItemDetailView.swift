import SwiftUI
import SwiftData
import PhotosUI

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var item: PackingItem
    @State private var pickerItem: PhotosPickerItem?
    @State private var showDeleteConfirm = false

    var body: some View {
        // Hoisted out of the PhotosPicker label closure: that closure is
        // @Sendable on iOS 18 SDKs, so referencing the MainActor `item`
        // inside it is a Swift 6 violation there (newer SDKs inherit the
        // actor context, which is why this shipped silently).
        let photoLabel = item.photoData == nil ? "Add photo" : "Change photo"
        return Form {
            Section {
                if let data = item.photoData, let ui = UIImage(data: data) {
                    Image(uiImage: ui).resizable().scaledToFit().frame(maxHeight: 220).clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityLabel("Item photo")
                    Button("Remove photo", role: .destructive) {
                        item.photoData = nil; try? context.save()
                        #if canImport(UIKit)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        #endif
                    }
                }
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label(photoLabel, systemImage: "photo")
                }
            }

            Section("Item") {
                TextField("Name", text: $item.name)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                Picker("Category", selection: $item.category) { ForEach(builtInCategoryNames, id: \.self) { Text($0).tag($0) } }
                Stepper("Quantity: \(item.quantity)", value: $item.quantity, in: 1...99)
                Toggle("Packed", isOn: $item.packed)
                Toggle("Essential", isOn: $item.essential)
                Toggle("Favorite", isOn: $item.isFavorite)
            }

            Section("Notes") {
                TextEditor(text: Binding(get: { item.notes ?? "" }, set: { item.notes = $0.isEmpty ? nil : $0 }))
                    .frame(minHeight: 80)
                    .accessibilityLabel("Notes")
                    .accessibilityHint("Add notes for this item")
            }

            Section {
                Text("Stored locally on device. Changes save automatically.").font(.caption).foregroundStyle(.secondary)
            }

            Section {
                Button("Delete item", role: .destructive) { showDeleteConfirm = true }
            }
        }
        .navigationTitle("Item Detail")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete this item?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                context.delete(item); try? context.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: pickerItem) { _, new in
            Task {
                if let data = try? await new?.loadTransferable(type: Data.self) {
                    // Downscale to keep local storage reasonable
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
        .onChange(of: item.packed) { _, new in
            try? context.save()
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
        }
        .onChange(of: item.essential) { _, _ in try? context.save() }
        .onChange(of: item.isFavorite) { _, _ in try? context.save() }
    }
}
