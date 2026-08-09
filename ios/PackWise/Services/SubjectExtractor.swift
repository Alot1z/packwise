import Foundation
import UIKit
import Vision
import CoreImage

/// On-device foreground subject extraction (background removal) for inventory items.
///
/// Uses `VNGenerateForegroundInstanceMaskRequest` (iOS 17+, exactly the app's
/// deployment target). The result is a transparent-background cutout plus a small
/// thumbnail, both persisted as PNG data by the caller. Everything runs locally —
/// no image ever leaves the device.
///
/// Availability: `VNGenerateForegroundInstanceMaskRequest` is iOS 17.0+,
/// `VNInstanceMaskObservation.generateMaskedImage(ofInstances:croppedToInstancesExtent:)`
/// is iOS 17.0+. No availability shim needed at the iOS 17 target.
@MainActor
final class SubjectExtractor {
    struct Extraction {
        /// The subject cut out on a transparent background (PNG-ready).
        let isolatedImage: UIImage
        /// Small square-ish preview for list rows.
        let thumbnail: UIImage
        /// Detection confidence (0...1) from the observation.
        let confidence: Float
    }

    enum ExtractionError: LocalizedError {
        case noImage
        case noSubject
        case renderingFailed

        var errorDescription: String? {
            switch self {
            case .noImage: return "Could not read the photo."
            case .noSubject: return "No clear subject found. Try a simpler background."
            case .renderingFailed: return "Could not render the cut-out. Using the original photo."
            }
        }
    }

    private let context = CIContext(options: [.useSoftwareRenderer: false])

    /// Extracts the foreground subject. Runs the Vision request off the main actor
    /// (the mask rendering can take a moment on large photos).
    func extract(from image: UIImage) async throws -> Extraction {
        let context = self.context
        return try await Task.detached(priority: .userInitiated) {
            try Self.extractSync(from: image, context: context)
        }.value
    }

    private nonisolated static func extractSync(from image: UIImage, context: CIContext) throws -> Extraction {
        guard let cg = image.cgImage else { throw ExtractionError.noImage }

        // Vision expects the photo's stored orientation — a raw `.up` would flip
        // portrait captures. Same mapping as VisionService.
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cg, orientation: Self.cgOrientation(for: image.imageOrientation), options: [:])
        try handler.perform([request])

        guard let observation = request.results?.first else { throw ExtractionError.noSubject }

        let instances = observation.allInstances
        guard !instances.isEmpty else { throw ExtractionError.noSubject }

        // All instances, not cropped to the instance extent — keep the original
        // frame so the cutout lines up with the source photo.
        let maskBuffer = try observation.generateMaskedImage(
            ofInstances: instances,
            from: handler,
            croppedToInstancesExtent: false
        )

        let maskImage = CIImage(cvPixelBuffer: maskBuffer)
        let extent = maskImage.extent
        guard let rendered = context.createCGImage(maskImage, from: extent) else {
            throw ExtractionError.renderingFailed
        }

        let isolated = UIImage(cgImage: rendered, scale: image.scale, orientation: .up)
        let thumbnail = Self.makeThumbnail(of: rendered)

        return Extraction(isolatedImage: isolated, thumbnail: thumbnail, confidence: observation.confidence)
    }

    /// Internal for unit tests (`@testable import`); pure function of the image.
    nonisolated static func makeThumbnail(of cg: CGImage) -> UIImage {
        let side: CGFloat = 240
        let scale = min(side / CGFloat(cg.width), side / CGFloat(cg.height), 1)
        let w = max(1, Int(CGFloat(cg.width) * scale))
        let h = max(1, Int(CGFloat(cg.height) * scale))
        guard let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return UIImage(cgImage: cg)
        }
        ctx.interpolationQuality = .high
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        guard let scaled = ctx.makeImage() else { return UIImage(cgImage: cg) }
        return UIImage(cgImage: scaled)
    }

    /// Internal for unit tests (`@testable import`); pure orientation mapping.
    nonisolated static func cgOrientation(for o: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch o {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
