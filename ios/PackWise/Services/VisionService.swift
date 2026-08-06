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
        if ["shirt","jacket","dress","jeans","trouser","coat","sweater","t-shirt","blouse","skirt","shorts","sock","shoe","sneaker","boot","sandal","hat","scarf","glove"].contains(where: l.contains) { return "Clothing" }
        if ["laptop","phone","camera","headphone","charger","cable","adapter","power","battery"].contains(where: l.contains) { return "Electronics" }
        if ["toothbrush","bottle","lotion","shampoo","soap","cosmetic"].contains(where: l.contains) { return "Toiletries" }
        if ["passport","document","book","paper"].contains(where: l.contains) { return "Documents" }
        if ["medicine","pill","bandage","first aid"].contains(where: l.contains) { return "Medical" }
        if ["sunglass","watch","jewelry","bag","backpack","suitcase","umbrella"].contains(where: l.contains) { return "Accessories" }
        if ["tent","backpack","bottle","compass","rope"].contains(where: l.contains) { return "Outdoor" }
        return "General"
    }

    func classify(image: UIImage) async {
        isProcessing = true
        error = nil
        suggestions = []
        guard let cg = image.cgImage else {
            error = "Could not read image."
            isProcessing = false
            return
        }
        do {
            let request = VNClassifyImageRequest()
            let handler = VNImageRequestHandler(cgImage: cg, orientation: .up, options: [:])
            try handler.perform([request])
            let results = (request.results ?? []).prefix(8)
            let mapped: [VisionSuggestion] = results
                .filter { $0.confidence > 0.15 }
                .map { obs in
                    let cat = self.category(for: obs.identifier)
                    return VisionSuggestion(label: obs.identifier.replacingOccurrences(of: ",", with: " ·").capitalized, confidence: obs.confidence, category: cat)
                }
            // Also try object detection for additional labels
            suggestions = mapped.isEmpty ? [VisionSuggestion(label: "Unrecognized — add manually", confidence: 0, category: "General")] : mapped
        } catch {
            self.error = error.localizedDescription
        }
        isProcessing = false
    }

    func reset() { suggestions = []; error = nil }
}
