import Foundation
import Vision
import UIKit

/// On-device Vision classification. Never modifies user data silently — caller must confirm.
@MainActor
final class VisionService: ObservableObject {
    @Published var isProcessing = false
    @Published var suggestions: [VisionSuggestion] = []
    @Published var error: String?

    struct VisionSuggestion: Identifiable, Hashable {
        let id = UUID()
        let label: String
        let confidence: Float
        let category: String

        var displayConfidence: String { String(format: "%.0f%%", confidence * 100) }
    }

    /// Map Vision labels → PackWise categories (conservative, local).
    private func category(for label: String) -> String {
        let l = label.lowercased()
        if ["shirt","jacket","dress","jeans","trouser","coat","sweater","t-shirt","blouse","skirt","shorts","sock","shoe","sneaker","boot","sandal","hat","scarf","glove","hoodie","parka","cardigan"].contains(where: l.contains) { return "Clothing" }
        if ["laptop","phone","camera","headphone","charger","cable","adapter","power","battery","keyboard","monitor","tablet","earphone"].contains(where: l.contains) { return "Electronics" }
        if ["toothbrush","bottle","lotion","shampoo","soap","cosmetic","deodorant","razor","perfume"].contains(where: l.contains) { return "Toiletries" }
        if ["passport","document","book","paper","notebook","envelope","folder"].contains(where: l.contains) { return "Documents" }
        if ["medicine","pill","bandage","first aid","capsule","syringe"].contains(where: l.contains) { return "Medical" }
        if ["sunglass","watch","jewelry","bag","backpack","suitcase","umbrella","belt","wallet","glasses"].contains(where: l.contains) { return "Accessories" }
        if ["tent","compass","rope","kayak","canoe","paddle","helmet","hiking","camping"].contains(where: l.contains) { return "Outdoor" }
        return "General"
    }

    func classify(image: UIImage) async {
        isProcessing = true
        error = nil
        suggestions = []
        guard let cg = image.cgImage else {
            error = "Could not read image. Try a different photo."
            isProcessing = false
            return
        }
        do {
            let request = VNClassifyImageRequest()
            // Respect the photo's stored rotation: UIImage.cgImage bakes no
            // orientation, so `.up` would misclassify portrait photos.
            let handler = VNImageRequestHandler(cgImage: cg, orientation: cgOrientation(image.imageOrientation), options: [:])
            try handler.perform([request])
            let results = (request.results ?? []).prefix(8)
            let mapped: [VisionSuggestion] = results
                .filter { $0.confidence > 0.12 }
                .map { obs in
                    let cat = self.category(for: obs.identifier)
                    return VisionSuggestion(label: obs.identifier.replacingOccurrences(of: ",", with: " ·").capitalized, confidence: obs.confidence, category: cat)
                }
            if mapped.isEmpty {
                suggestions = [VisionSuggestion(label: "Unrecognized — add manually", confidence: 0, category: "General")]
            } else {
                suggestions = mapped
            }
        } catch {
            self.error = error.localizedDescription
        }
        isProcessing = false
    }

    func reset() { suggestions = []; error = nil; isProcessing = false }

    /// Maps UIImage orientation → Vision's CGImagePropertyOrientation.
    private func cgOrientation(_ o: UIImage.Orientation) -> CGImagePropertyOrientation {
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
