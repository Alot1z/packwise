import Foundation
import CoreLocation
import WeatherKit

/// A small, Codable, Sendable snapshot of the weather at a trip destination.
///
/// Kept deliberately small and value-type so `RecommendationService` (pure, testable)
/// can consume it without importing WeatherKit and without any network dependency.
struct WeatherSnapshot: Codable, Sendable, Equatable {
    /// Current temperature in °C.
    let temperatureC: Double
    /// Human-readable condition, e.g. "Rain", "Partly Cloudy".
    let condition: String
    /// SF Symbol name for the current condition (e.g. "cloud.rain").
    let symbolName: String
    /// Upcoming daily forecast relevant to the trip (sorted by date).
    let daily: [WeatherDay]

    struct WeatherDay: Codable, Sendable, Equatable {
        let date: Date
        /// High temperature in °C.
        let highC: Double
        /// Low temperature in °C.
        let lowC: Double
        let condition: String
        let symbolName: String
        /// 0...1 chance of precipitation.
        let precipitationChance: Double
    }
}

/// Fetches live weather for a destination coordinate via WeatherKit.
///
/// PackWise ships unsigned, so the `com.apple.developer.weatherkit` entitlement is
/// **not** available in sideloaded builds — every fetch can fail. That is expected:
/// every method returns `nil` on any failure (entitlement, network, location) and
/// callers fall back to the deterministic text-based recommendation engine. Weather
/// is an enhancement, never a blocker.
enum WeatherProvider {
    private static let service = WeatherService.shared

    /// Live forecast for a coordinate. Returns nil when unavailable for any reason.
    static func snapshot(for coordinate: CLLocationCoordinate2D) async -> WeatherSnapshot? {
        guard CLLocationCoordinate2DIsValid(coordinate) else { return nil }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        do {
            let weather = try await service.weather(for: location)

            let current = weather.currentWeather
            let daily: [WeatherSnapshot.WeatherDay] = weather.dailyForecast.forecast.map { day in
                WeatherSnapshot.WeatherDay(
                    date: day.date,
                    highC: day.highTemperature.converted(to: .celsius).value,
                    lowC: day.lowTemperature.converted(to: .celsius).value,
                    condition: day.condition.description,
                    symbolName: day.symbolName,
                    precipitationChance: day.precipitationChance
                )
            }

            return WeatherSnapshot(
                temperatureC: current.temperature.converted(to: .celsius).value,
                condition: current.condition.description,
                symbolName: current.symbolName,
                daily: daily
            )
        } catch {
            return nil
        }
    }

    /// Average of daily precipitation chances across the trip's date range
    /// (inclusive). Returns nil when there is no forecast data for those days.
    static func precipitationChance(in snapshot: WeatherSnapshot, from start: Date?, to end: Date?) -> Double? {
        guard let start, let end else { return nil }
        let days = snapshot.daily.filter { day in
            let dayStart = Calendar.current.startOfDay(for: day.date)
            return dayStart >= Calendar.current.startOfDay(for: start)
                && dayStart <= Calendar.current.startOfDay(for: end)
        }
        guard !days.isEmpty else { return nil }
        return days.map(\.precipitationChance).reduce(0, +) / Double(days.count)
    }

    /// Coldest low across the trip's date range.
    static func coldestLow(in snapshot: WeatherSnapshot, from start: Date?, to end: Date?) -> Double? {
        guard let start, let end else { return nil }
        let lows = snapshot.daily
            .filter { day in
                let dayStart = Calendar.current.startOfDay(for: day.date)
                return dayStart >= Calendar.current.startOfDay(for: start)
                    && dayStart <= Calendar.current.startOfDay(for: end)
            }
            .map(\.lowC)
        return lows.min()
    }
}
