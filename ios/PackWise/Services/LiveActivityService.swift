import ActivityKit
import Foundation
import SwiftData

/// Starts, updates, and ends the trip-departure Live Activity
/// (Lock Screen + Dynamic Island).
///
/// The service is `@MainActor`-isolated so `Activity` values never cross
/// actor boundaries — safe under Swift 6 strict concurrency without marking
/// the type `Sendable`. All ActivityKit calls are awaited inline (no `Task`
/// captures of non-Sendable values).
@MainActor
final class LiveActivityService {
    static let shared = LiveActivityService()
    private init() {}

    /// The active activity for a trip, if any.
    private func activeActivity(for tripID: UUID) -> Activity<TripActivityAttributes>? {
        Activity<TripActivityAttributes>.activities.first { $0.attributes.tripID == tripID }
    }

    /// Brings the trip's Live Activity in line with reality:
    /// - outside the presentation window → ends any running activity;
    /// - inside the window with an existing activity → updates its content;
    /// - inside the window with none → requests a new activity.
    ///
    /// Returns whether an activity is (now) present.
    @discardableResult
    func sync(for trip: Trip) async -> Bool {
        let now = Date()
        guard TripActivitySupport.shouldPresent(departure: trip.startDate, end: trip.endDate, now: now) else {
            await end(for: trip)
            return false
        }
        let attributes = TripActivityAttributes(
            tripID: trip.id,
            tripName: trip.title,
            destination: trip.destination,
            departureDate: trip.startDate,
            endDate: trip.endDate
        )
        let state = TripActivityAttributes.ContentState(
            packedCount: trip.items.filter(\.packed).count,
            totalCount: trip.items.count
        )
        if let activity = activeActivity(for: trip.id) {
            await activity.update(ActivityContent(state: state, staleDate: nil))
            return true
        }
        do {
            _ = try await Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
            return true
        } catch {
            // ActivityKit unavailable, or the user disabled Live Activities.
            return false
        }
    }

    /// Ends the trip's activity immediately, if one is running.
    func end(for trip: Trip) async {
        guard let activity = activeActivity(for: trip.id) else { return }
        await activity.end(nil, dismissalPolicy: .immediate)
    }

    /// Self-healing pass over every trip — call on app/trips-list appear so
    /// activities survive relaunches and stay in sync with reality.
    func syncAll(_ trips: [Trip]) async {
        for trip in trips {
            await sync(for: trip)
        }
    }
}
