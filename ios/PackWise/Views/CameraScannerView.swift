import SwiftUI
import SwiftData
import PhotosUI
import UIKit

/// The FullPack-style scanner: live camera preview → capture (or import) →
/// on-device background removal → Vision suggestions → confirm → add to trip.
///
/// Privacy: every step is on-device. No image leaves the device; nothing is added
/// to a trip without the user confirming.
struct CameraScannerView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]

    @StateObject private var camera = CameraService()
    @StateObject private var vision = VisionService()

    // Capture-review state
    @State private var reviewImage: UIImage?
    @State private var isolatedImage: UIImage?
    @State private var extractError: String?
    @State private var isExtracting = false
    @State private var showDissolve = false
    /// The raw capture, kept for the dissolve backdrop even while the isolated
    /// cutout replaces it in the review form.
    @State private var originalCaptured: UIImage?
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedTripID: UUID?
    @State private var selected: Set<UUID> = []
    @State private var manualName = ""
    @State private var showFlash = false
    @State private var animateShutter = false

    private let extractor = SubjectExtractor()

    var body: some View {
        NavigationStack {
            Group {
                if showDissolve, let original = originalCaptured {
                    ParticleDissolveView(
                        sourceImage: original,
                        isolatedImage: isolatedImage,
                        onComplete: {
                            withAnimation(reduceMotion ? nil : PackWiseDesign.Animation.standard) {
                                showDissolve = false
                            }
                        }
                    )
                    .transition(.opacity)
                } else if let review = reviewImage {
                    reviewFlow(review)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                } else {
                    liveCamera
                        .transition(.opacity)
                }
            }
            .animation(reduceMotion ? nil : PackWiseDesign.Animation.standard, value: reviewImage != nil || showDissolve)
            .navigationTitle("Scanner")
            .toolbar {
                if reviewImage != nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { resetReview() }
                            .accessibilityLabel("Cancel review")
                    }
                }
            }
            .task { await camera.start() }
            .onDisappear { camera.stop() }
            .onChange(of: pickerItem) { _, v in
                Task {
                    if let data = try? await v?.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        beginReview(with: img)
                    }
                }
            }
        }
    }

    // MARK: - Live camera

    private var liveCamera: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch camera.status {
            case .unauthorized:
                unauthorizedView
            case .starting, .idle:
                ProgressView("Preparing camera…").tint(.white).foregroundStyle(.white)
                    .accessibilityLabel("Preparing camera")
            case .failed(let message):
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill").font(.largeTitle).foregroundStyle(.yellow)
                    Text(message).foregroundStyle(.white).multilineTextAlignment(.center)
                    importFallbackButton
                }.padding()
            case .running:
                CameraPreview(session: camera.session)
                    .ignoresSafeArea()
                    .overlay(alignment: .bottom) { cameraControls }
            }

            if case .running = camera.status {
                // framing hint
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(.white.opacity(0.35), lineWidth: 2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(28)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }

            // Capture flash overlay
            if showFlash {
                Color.white
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .overlay(alignment: .top) {
            Text("Center the item, then capture")
                .font(.caption).foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(.black.opacity(0.45), in: Capsule())
                .padding(.top, 8)
                .accessibilityHidden(true)
        }
    }

    private var cameraControls: some View {
        HStack(spacing: 36) {
            Button {
                withAnimation(PackWiseDesign.Animation.fast) {
                    camera.flipCamera()
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .font(.title2)
                    .accessibilityLabel("Switch camera")
            }
            .tint(.white)

            Button {
                withAnimation(PackWiseDesign.Animation.bouncy) {
                    animateShutter = true
                }
                Task {
                    if let image = try? await camera.capturePhoto() {
                        withAnimation(PackWiseDesign.Animation.bouncy) {
                            showFlash = true
                        }
                        try? await Task.sleep(nanoseconds: 150_000_000)
                        withAnimation(PackWiseDesign.Animation.fast) {
                            showFlash = false
                            animateShutter = false
                        }
                        beginReview(with: image)
                    } else {
                        withAnimation(PackWiseDesign.Animation.fast) {
                            animateShutter = false
                        }
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(.white, lineWidth: 4)
                        .frame(width: 72, height: 72)
                        .scaleEffect(animateShutter ? 0.92 : 1.0)
                    if camera.isCapturing {
                        ProgressView().tint(.white)
                    } else {
                        Circle()
                            .fill(.white)
                            .frame(width: 58, height: 58)
                            .scaleEffect(animateShutter ? 0.85 : 1.0)
                    }
                }
            }
            .accessibilityLabel("Take photo")
            .disabled(camera.isCapturing)

            importButton
        }
        .padding(.bottom, 28)
    }

    private var importButton: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            Image(systemName: "photo.on.rectangle")
                .font(.title2)
                .accessibilityLabel("Import photo")
        }
        .tint(.white)
    }

    private var importFallbackButton: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            Label("Import a photo instead", systemImage: "photo.on.rectangle")
                .font(.headline).padding()
        }
        .buttonStyle(.borderedProminent)
    }

    private var unauthorizedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill").font(.largeTitle).foregroundStyle(.secondary)
            Text("Camera access is off").font(.headline)
            Text("PackWise uses the camera to photograph items for your private packing list. Enable camera access in Settings to scan items, or import a photo instead.")
                .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 24)
            importFallbackButton
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.bordered)
        }
        .foregroundStyle(.white)
    }

    // MARK: - Review flow

    private func reviewFlow(_ image: UIImage) -> some View {
        Form {
            Section("Photo") {
                if let isolated = isolatedImage {
                    Image(uiImage: isolated).resizable().scaledToFit().frame(maxHeight: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityLabel("Item cut out with background removed")
                } else {
                    Image(uiImage: image).resizable().scaledToFit().frame(maxHeight: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityLabel("Captured photo")
                }

                if isExtracting {
                    HStack(spacing: 8) {
                        ProgressView().tint(.accentColor)
                        Text("Removing background on device…").font(.caption).foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Removing background on device")
                }

                if let e = extractError {
                    Label(e, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption).foregroundStyle(Color(red: 0.74, green: 0.18, blue: 0.12))
                        .accessibilityLabel(e)
                }

                Label("Background removal and suggestions run on device. Nothing is uploaded.", systemImage: "lock.shield")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Section("Name") {
                TextField("Item name", text: $manualName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .accessibilityLabel("Item name")
            }

            Section("Suggestions — tap to pick a name & category") {
                Picker("Add to trip", selection: $selectedTripID) {
                    Text("Choose trip").tag(nil as UUID?)
                    ForEach(trips) { Text($0.title).tag($0.id as UUID?) }
                }
                if vision.suggestions.isEmpty {
                    Text("No suggestions found — type a name above.").font(.caption).foregroundStyle(.secondary)
                }
                ForEach(vision.suggestions) { s in
                    Button {
                        if selected.contains(s.id) { selected.remove(s.id) } else {
                            selected = [s.id]
                            manualName = s.label
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(s.label).font(.subheadline).foregroundStyle(.primary)
                                Text("\(s.category) · \(s.displayConfidence)").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if selected.contains(s.id) {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).accessibilityHidden(true)
                            }
                        }
                    }
                    .accessibilityAddTraits(selected.contains(s.id) ? .isSelected : [])
                    .accessibilityLabel("\(s.label), \(s.category), \(s.displayConfidence)")
                    .accessibilityHint("Double-tap to use this name and category")
                }
            }

            Section {
                Button {
                    addToTrip(from: image)
                } label: {
                    Label("Add to trip", systemImage: "checkmark.circle")
                }
                .disabled(selectedTripID == nil || name.isEmpty)
                .accessibilityHint("Adds the item to the chosen trip with the selected name and photo")
            }
        }
        .listStyle(.insetGrouped)
    }

    private var name: String { manualName.trimmingCharacters(in: .whitespaces) }

    // MARK: - Actions

    private func beginReview(with image: UIImage) {
        originalCaptured = image
        reviewImage = image
        resetReviewState(keepImage: true)
        // Play the FullPack-style dissolve while extraction runs underneath.
        withAnimation(reduceMotion ? nil : PackWiseDesign.Animation.standard) {
            showDissolve = true
        }
        // Classify + extract in parallel.
        Task { await vision.classify(image: image) }
        Task {
            isExtracting = true
            defer { isExtracting = false }
            do {
                let extraction = try await extractor.extract(from: image)
                isolatedImage = extraction.isolatedImage
            } catch let e as SubjectExtractor.ExtractionError {
                extractError = e.errorDescription
            } catch {
                extractError = SubjectExtractor.ExtractionError.renderingFailed.errorDescription
            }
        }
    }

    private func addToTrip(from original: UIImage) {
        guard let tid = selectedTripID, let trip = trips.first(where: { $0.id == tid }) else { return }

        let suggestion = vision.suggestions.first { selected.contains($0.id) }
        let item = PackingItem(
            name: name,
            category: suggestion?.category ?? "General",
            trip: trip
        )

        // Persist the isolated cutout when available; otherwise the original photo.
        let imageData = isolatedImage?.pngData() ?? original.jpegData(compressionQuality: 0.8)
        item.photoData = imageData

        context.insert(item)
        trip.updatedAt = Date()
        try? context.save()

        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif

        resetReview()
    }

    private func resetReviewState(keepImage: Bool = false) {
        if !keepImage { reviewImage = nil }
        isolatedImage = nil
        extractError = nil
        selected = []
        manualName = ""
        vision.reset()
    }

    private func resetReview() {
        resetReviewState(keepImage: false)
        showDissolve = false
        selectedTripID = nil
    }
}
