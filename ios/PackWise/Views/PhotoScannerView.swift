import SwiftUI
import PhotosUI
import SwiftData

struct PhotoScannerView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]
    @StateObject private var vision = VisionService()
    @State private var pickerItem: PhotosPickerItem?
    @State private var uiImage: UIImage?
    @State private var selectedTripID: UUID?
    @State private var selected: Set<UUID> = []

    var body: some View {
        NavigationStack {
            List {
                Section("Photo") {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Import photo", systemImage: "photo.on.rectangle.angled")
                    }
                    if let img = uiImage {
                        Image(uiImage: img).resizable().scaledToFit().frame(maxHeight: 260).clipShape(RoundedRectangle(cornerRadius: 12))
                            .accessibilityLabel("Imported photo")
                        if vision.isProcessing { ProgressView("Analysing on device…") }
                    }
                    Button("Analyse on device") {
                        guard let img = uiImage else { return }
                        Task { await vision.classify(image: img) }
                    }.disabled(uiImage == nil || vision.isProcessing)
                    if let e = vision.error { Text(e).font(.caption).foregroundStyle(.red) }
                    Text("Vision runs locally. No image leaves your device. Suggestions require your confirmation.").font(.caption).foregroundStyle(.secondary)
                }

                if !vision.suggestions.isEmpty {
                    Section("Suggestions — confirm to add") {
                        Picker("Add to trip", selection: $selectedTripID) {
                            Text("Choose trip").tag(nil as UUID?)
                            ForEach(trips) { Text($0.title).tag($0.id as UUID?) }
                        }
                        ForEach(vision.suggestions) { s in
                            Button {
                                if selected.contains(s.id) { selected.remove(s.id) } else { selected.insert(s.id) }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(s.label).font(.subheadline).foregroundStyle(.primary)
                                        Text("\(s.category) · \(s.displayConfidence)").font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if selected.contains(s.id) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).accessibilityHidden(true) }
                                }
                            }
                            .accessibilityAddTraits(selected.contains(s.id) ? .isSelected : [])
                        }
                        Button("Add selected to trip") {
                            guard let tid = selectedTripID, let trip = trips.first(where: { $0.id == tid }) else { return }
                            for s in vision.suggestions where selected.contains(s.id) {
                                let item = PackingItem(name: s.label, category: s.category, trip: trip)
                                context.insert(item)
                            }
                            trip.updatedAt = Date()
                            try? context.save()
                            selected = []
                        }.disabled(selectedTripID == nil || selected.isEmpty)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Photo Scanner")
            .onChange(of: pickerItem) { _, v in
                Task {
                    if let data = try? await v?.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                        uiImage = img
                        vision.reset()
                        selected = []
                    }
                }
            }
        }
    }
}
