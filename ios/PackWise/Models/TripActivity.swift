import ActivityKit
import Foundation

// MARK: - Live Activity Attributes (shared: app + widget targets)

/// ActivityKit attributes for the trip-departure Live Activity.
/// Lives in `Models/` so both the app and the widget extension compile it —
/// the two targets must agree on this exact Codable shape.
struct TripActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var packedCount: Int
        var totalCount: Int
    }

    var tripID: UUID
    var tripName: String
    var destination: String
    var departureDate: Date?
    var endDate: Date?
}

// MARK: - Pure, testable support logic

/// Deterministic policy + formatting for the departure Live Activity.
/// No ActivityKit calls here — every function is a pure function of its inputs,
/// so the whole policy is unit-testable without a device.
enum TripActivitySupport {
    /// Packing progress clamped to 0...1; 0 when there is nothing to pack.
    static func progress(packed: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return min(1, max(0, Double(packed) / Double(total)))
    }

    /// Whether a departure Live Activity should be presented right now.
    ///
    /// - Requires a departure date (no date, no countdown).
    /// - Ends once the trip is over (`end < now`).
    /// - Only starts within `leadWindow` (default 24 hours) of departure —
    ///   Live Activities are display-limited by the system, and the countdown
    ///   matters most in the final day. An ongoing trip (departed, not ended)
    ///   stays live until its end date.
    static func shouldPresent(departure: Date?, end: Date?, now: Date, leadWindow: TimeInterval = 24 * 60 * 60) -> Bool {
        guard let departure else { return false }
        if let end, end < now { return false }
        let windowStart = departure.addingTimeInterval(-leadWindow)
        return now >= windowStart
    }

    /// Compact countdown label for the lock screen: "2d 4h", "3h 12m", "45m",
    /// "Now", or "Departed" once the departure moment has passed.
    static func countdownLabel(departure: Date?, now: Date) -> String {
        guard let departure else { return "—" }
        let remaining = departure.timeIntervalSince(now)
        if remaining <= 0 { return "Departed" }
        let totalMinutes = Int(remaining) / 60
        if totalMinutes <= 0 { return "Now" }
        let days = totalMinutes / 1440
        let hours = (totalMinutes % 1440) / 60
        let minutes = totalMinutes % 60
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}
