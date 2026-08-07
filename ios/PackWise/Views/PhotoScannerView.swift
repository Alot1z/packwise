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
                            .contextMenu {
                                Button("Clear photo", role: .destructive) {
                                    uiImage = nil; vision.reset(); selected = []
                                }
                            }
                        if vision.isProcessing {
                            HStack(spacing: 8) {
                                ProgressView().tint(.accentColor)
                                Text("Analysing on device…").font(.caption).foregroundStyle(.secondary)
                            }
                            .accessibilityLabel("Analysing image on device")
                        }
                    }
                    Button("Analyse on device") {
                        guard let img = uiImage else { return }
                        Task { await vision.classify(image: img) }
                    }
                    .disabled(uiImage == nil || vision.isProcessing)
                    .accessibilityHint("Runs Vision classification locally. No image leaves your device.")

                    if let e = vision.error {
                        Label(e, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color(red: 0.74, green: 0.18, blue: 0.12))
                    }
                    Label("Vision runs locally. No image leaves your device. Suggestions require your confirmation.", systemImage: "lock.shield")
                        .font(.caption).foregroundStyle(.secondary)
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
                                #if canImport(UIKit)
                                UISelectionFeedbackGenerator().selectionChanged()
                                #endif
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
                            .accessibilityLabel("\(s.label), \(s.category), \(s.displayConfidence) — \(selected.contains(s.id) ? "selected" : "not selected")")
                            .accessibilityHint("Double-tap to toggle selection")
                        }
                        Button("Add selected to trip") {
                            guard let tid = selectedTripID, let trip = trips.first(where: { $0.id == tid }) else { return }
                            for s in vision.suggestions where selected.contains(s.id) {
                                let item = PackingItem(name: s.label, category: s.category, trip: trip)
                                context.insert(item)
                            }
                            trip.updatedAt = Date()
                            try? context.save()
                            #if canImport(UIKit)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            #endif
                            selected = []
                        }.disabled(selectedTripID == nil || selected.isEmpty)
                    }
                } else if uiImage != nil && !vision.isProcessing && vision.error == nil {
                    Section {
                        Text("Tap Analyse to get on-device suggestions, then confirm which to add.").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Photo Scanner")
            .toolbar {
                if uiImage != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") { uiImage = nil; vision.reset(); selected = [] }
                            .font(.caption)
                    }
                }
            }
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
