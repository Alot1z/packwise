import AVFoundation
import UIKit

/// Live camera capture for the inventory scanner.
///
/// Wraps an `AVCaptureSession` (back/front camera, still photo output) behind a small
/// async API. Permission is requested with the iOS 17 async variant of
/// `AVCaptureDevice.requestAccess(for:)`; every state is published so the view can
/// render an appropriate UI (preview, spinner, unauthorized, failed).
///
/// All session work happens on a private serial queue; state flips land on the main
/// actor. Captured photos come back as `UIImage` (EXIF orientation preserved by the
/// JPEG data).
@MainActor
final class CameraService: NSObject, ObservableObject {
    enum Status: Equatable {
        case idle
        case starting
        case running
        case unauthorized
        case failed(String)
    }

    enum CameraError: LocalizedError {
        case notRunning
        case noDevice
        case invalidData
        case unknown

        var errorDescription: String? {
            switch self {
            case .notRunning: return "The camera is not ready yet."
            case .noDevice: return "No camera is available on this device."
            case .invalidData: return "Could not read the captured photo."
            case .unknown: return "The camera failed unexpectedly."
            }
        }
    }

    @Published var status: Status = .idle
    @Published var isCapturing = false

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "com.packwise.camera.session", qos: .userInitiated)
    private let photoOutput = AVCapturePhotoOutput()
    private var currentInput: AVCaptureDeviceInput?
    private var pendingPhoto: CheckedContinuation<UIImage, Error>?
    private var activeDelegate: PhotoCaptureDelegate?
    private var cameraPosition: AVCaptureDevice.Position = .back

    override init() {
        super.init()
    }

    // NOTE: no deinit touching `session`/`sessionQueue` — they are
    // MainActor-isolated stored properties, and Swift 6 forbids accessing
    // non-Sendable state from a nonisolated deinit. AVCaptureSession stops
    // capturing automatically when it is deallocated; explicit shutdown is
    // available via stop().

    /// Requests camera permission (if needed) and starts the session.
    func start() async {
        guard status != .running else { return }

        let authorized: Bool
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            authorized = true
        case .notDetermined:
            authorized = await AVCaptureDevice.requestAccess(for: .video)
        default:
            authorized = false
        }

        guard authorized else {
            status = .unauthorized
            return
        }

        status = .starting
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configureSession(position: self.cameraPosition)
            self.session.startRunning()
            let running = self.session.isRunning
            Task { @MainActor in
                self.status = running ? .running : .failed("Could not start the camera session.")
            }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    /// Flips between the front and back camera.
    func flipCamera() {
        let next: AVCaptureDevice.Position = cameraPosition == .back ? .front : .back
        cameraPosition = next
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configureSession(position: next)
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    /// Captures one still photo. Throws when the session is not running or the
    /// capture fails.
    func capturePhoto() async throws -> UIImage {
        guard status == .running else { throw CameraError.notRunning }
        guard !isCapturing else { throw CameraError.notRunning }

        isCapturing = true
        defer { isCapturing = false }

        let settings = AVCapturePhotoSettings()
        if let device = currentInput?.device, device.hasFlash {
            settings.flashMode = .auto
        }

        let delegate = PhotoCaptureDelegate()
        activeDelegate = delegate

        return try await withCheckedThrowingContinuation { continuation in
            pendingPhoto = continuation
            photoOutput.capturePhoto(with: settings, delegate: delegate)
            delegate.onFinish = { [weak self] result in
                // onFinish may fire from a nonisolated context; hop to the
                // main actor before touching MainActor-isolated state.
                Task { @MainActor in
                    self?.pendingPhoto = nil
                    self?.activeDelegate = nil
                }
                continuation.resume(with: result)
            }
        }
    }

    // MARK: - Private

    private func configureSession(position: AVCaptureDevice.Position) {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Tear down any previous input before adding the new camera.
        if let currentInput {
            session.removeInput(currentInput)
        }
        session.outputs.forEach { session.removeOutput($0) }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)
        currentInput = input

        if session.canAddOutput(photoOutput) {
            photoOutput.maxPhotoQualityPrioritization = .quality
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()
    }
}

// MARK: - Capture delegate

/// Bridges `AVCapturePhotoCaptureDelegate` callbacks (delivered on the session's
/// delegate queue) to a completion handler on the main actor.
private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    var onFinish: ((Result<UIImage, Error>) -> Void)?

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let result: Result<UIImage, Error>
        if let error {
            result = .failure(error)
        } else if let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data, scale: 1) {
            result = .success(image)
        } else {
            result = .failure(CameraService.CameraError.invalidData)
        }
        DispatchQueue.main.async { [weak self] in
            self?.onFinish?(result)
        }
    }
}
