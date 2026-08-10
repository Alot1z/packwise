import Foundation
// @preconcurrency: MKLocalSearchCompletion / MKLocalSearchCompleter are not
// yet Sendable-annotated in the SDK; the preconcurrency import lets these
// (main-thread-delivered) results cross into the @MainActor Task without
// Swift 6 "sending" errors. The delegate is called on the main thread, so
// the transfer is runtime-safe.
@preconcurrency import MapKit
import CoreLocation
import Combine

/// Destination place autocomplete + coordinate resolution for trips.
///
/// Uses `MKLocalSearchCompleter` (iOS 9.3+) for type-ahead place suggestions and
/// `MKLocalSearch` (iOS 13+) to resolve a chosen suggestion to a coordinate. The
/// view asks for a coordinate after the user picks a suggestion; `MKMapItem`'s
/// `placemark.coordinate` supplies it (no manual lat/lon entry needed).
@MainActor
final class DestinationSearchService: NSObject, ObservableObject {
    @Published var suggestions: [MKLocalSearchCompletion] = []
    @Published var isSearching = false

    private let completer: MKLocalSearchCompleter
    private var debounceTask: Task<Void, Never>?

    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = .pointOfInterest
        completer.pointOfInterestFilter = .includingAll
    }

    /// Debounced query update from the destination text field.
    func updateQuery(_ text: String) {
        debounceTask?.cancel()
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            suggestions = []
            isSearching = false
            completer.cancel()
            return
        }
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            self?.completer.queryFragment = trimmed
        }
    }

    /// Resolves a selected suggestion to its coordinate.
    func coordinate(for completion: MKLocalSearchCompletion) async -> CLLocationCoordinate2D? {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            return response.mapItems.first?.placemark.coordinate
        } catch {
            return nil
        }
    }

    /// Geocoding fallback: resolves a free-text destination string (typed directly
    /// by the user without picking a completer suggestion) to a coordinate using
    /// `CLGeocoder`. Runs on a background task so it never blocks the UI.
    static func geocode(destination text: String) async -> CLLocationCoordinate2D? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        do {
            let placemarks = try await CLGeocoder().geocodeAddressString(trimmed)
            guard let location = placemarks.first?.location else { return nil }
            return location.coordinate
        } catch {
            return nil
        }
    }

    func reset() {
        debounceTask?.cancel()
        completer.cancel()
        suggestions = []
        isSearching = false
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension DestinationSearchService: MKLocalSearchCompleterDelegate {
    // The delegate is called on the main thread, so the transfer is runtime-
    // safe; `self` must be captured WEAKLY — sending the MainActor-isolated
    // instance strongly from a nonisolated context into the @MainActor Task
    // is a Swift 6 violation on iOS 18 SDKs (newer SDKs allow it).
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = Array(completer.results.prefix(6))
        Task { [weak self] @MainActor in
            self?.suggestions = results
            self?.isSearching = !results.isEmpty
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { [weak self] @MainActor in
            self?.suggestions = []
            self?.isSearching = false
        }
    }
}
