import Foundation

/// Local, rule-based recommendations. No network, no cloud model.
/// Every suggestion is deterministic from trip fields and existing items.
enum RecommendationService {
    struct Suggestion: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let reason: String
        let category: String
    }

    /// Existing text-based engine — kept as the always-available fallback.
    static func suggestions(for trip: Trip) -> [Suggestion] {
        suggestions(for: trip, weather: nil)
    }

    /// Text-based suggestions merged with weather-based ones when a live
    /// `WeatherSnapshot` is available. Pure and deterministic — fully testable
    /// without network access.
    static func suggestions(for trip: Trip, weather: WeatherSnapshot?) -> [Suggestion] {
        var out: [Suggestion] = weatherSuggestions(for: trip, weather: weather)
        out.append(contentsOf: textSuggestions(for: trip))

        // Dedupe against existing items (case-insensitive) and within suggestions
        let existing = Set(trip.items.map { $0.name.lowercased() })
        var seen = Set<String>()
        return out.filter { s in
            let k = s.title.lowercased()
            guard !existing.contains(k), !seen.contains(k) else { return false }
            seen.insert(k)
            return true
        }
    }

    /// Deterministic weather rules. Empty when weather is nil (the app is fully
    /// functional offline without WeatherKit).
    static func weatherSuggestions(for trip: Trip, weather: WeatherSnapshot?) -> [Suggestion] {
        guard let weather else { return [] }
        var out: [Suggestion] = []
        let cond = weather.condition.lowercased()
        let start = trip.startDate
        let end = trip.endDate

        // Precipitation risk across the trip's date range.
        let precip = WeatherProvider.precipitationChance(in: weather, from: start, to: end)
        if let precip, precip >= 0.5 {
            out.append(Suggestion(title: "Umbrella", reason: "\(Int(precip * 100))% chance of precipitation", category: "Accessories"))
            out.append(Suggestion(title: "Rain shell", reason: "Rain likely during your trip", category: "Outdoor"))
        }

        // Cold lows → warm layers.
        if let low = WeatherProvider.coldestLow(in: weather, from: start, to: end), low < 5 {
            out.append(Suggestion(title: "Warm layers", reason: "Lows of \(Int(low))°C", category: "Clothing"))
            out.append(Suggestion(title: "Gloves", reason: "Cold conditions", category: "Accessories"))
        }

        // Current condition heuristics (when no date range is set).
        if cond.contains("rain") || cond.contains("shower") || cond.contains("thunder") {
            out.append(Suggestion(title: "Umbrella", reason: "\(weather.condition) expected", category: "Accessories"))
        }
        if cond.contains("snow") || cond.contains("sleet") || cond.contains("blizzard") {
            out.append(Suggestion(title: "Warm layers", reason: "\(weather.condition) conditions", category: "Clothing"))
        }
        if weather.temperatureC >= 28 {
            out.append(Suggestion(title: "Sunscreen", reason: "\(Int(weather.temperatureC))°C — sun protection", category: "Medical"))
            out.append(Suggestion(title: "Sunglasses", reason: "Bright, warm conditions", category: "Accessories"))
        } else if weather.temperatureC <= 10 {
            out.append(Suggestion(title: "Warm layers", reason: "\(Int(weather.temperatureC))°C at destination", category: "Clothing"))
        }

        return out
    }

    private static func textSuggestions(for trip: Trip) -> [Suggestion] {
        var out: [Suggestion] = []
        let dest = (trip.destination + " " + (trip.purpose ?? "") + " " + (trip.activities ?? "") + " " + (trip.climateInfo ?? "")).lowercased()
        // Inclusive day count: Jan 1 → Jan 3 is 3 days of travel.
        let days: Int = {
            guard let s = trip.startDate, let e = trip.endDate else { return 0 }
            let day = Calendar.current.dateComponents([.day], from: s, to: e).day ?? 0
            return max(1, day + 1)
        }()

        if dest.contains("beach") || dest.contains("coast") || dest.contains("tropical") || dest.contains("island") {
            out.append(Suggestion(title: "Sunscreen", reason: "Destination suggests sun exposure", category: "Medical"))
            out.append(Suggestion(title: "Sunglasses", reason: "Bright conditions", category: "Accessories"))
            if !dest.contains("hotel") {
                out.append(Suggestion(title: "Swim shorts", reason: "Beach destination", category: "Clothing"))
            }
        }
        if dest.contains("hiking") || dest.contains("trail") || dest.contains("mountain") || dest.contains("outdoor") {
            out.append(Suggestion(title: "Hiking boots", reason: "Activities include outdoors", category: "Outdoor"))
            out.append(Suggestion(title: "Rain shell", reason: "Weather variability", category: "Outdoor"))
            out.append(Suggestion(title: "Water bottle", reason: "Outdoor activity", category: "Outdoor"))
        }
        if dest.contains("business") || dest.contains("meeting") || dest.contains("conference") || dest.contains("work") {
            out.append(Suggestion(title: "Blazer", reason: "Business context", category: "Clothing"))
            out.append(Suggestion(title: "Notebook", reason: "Meetings", category: "Documents"))
        }
        if dest.contains("cold") || dest.contains("snow") || dest.contains("winter") || dest.contains("ski") {
            out.append(Suggestion(title: "Warm layers", reason: "Cold climate", category: "Clothing"))
            out.append(Suggestion(title: "Gloves", reason: "Cold weather", category: "Accessories"))
        }
        if dest.contains("rain") || dest.contains("wet") || dest.contains("monsoon") {
            out.append(Suggestion(title: "Umbrella", reason: "Rain expected", category: "Accessories"))
            out.append(Suggestion(title: "Waterproof bag", reason: "Wet conditions", category: "Accessories"))
        }
        if days >= 4 {
            out.append(Suggestion(title: "Laundry kit", reason: "Trip length \(days) days", category: "Toiletries"))
        }
        if days >= 7 {
            out.append(Suggestion(title: "Medications", reason: "Extended trip", category: "Medical"))
        }
        // International heuristic
        if dest.contains("international") || dest.contains("japan") || dest.contains("europe") || dest.contains("abroad") || trip.tripCategory == "International" {
            out.append(Suggestion(title: "Power adapter", reason: "International travel", category: "Electronics"))
            out.append(Suggestion(title: "Passport", reason: "International travel", category: "Documents"))
        }
        // Always useful — only if not already present
        if trip.items.isEmpty {
            out.append(Suggestion(title: "Charger and cable", reason: "Essentials", category: "Electronics"))
        }

        // Dedupe against existing items (case-insensitive) and within suggestions
        let existing = Set(trip.items.map { $0.name.lowercased() })
        var seen = Set<String>()
        return out.filter { s in
            let k = s.title.lowercased()
            guard !existing.contains(k), !seen.contains(k) else { return false }
            seen.insert(k)
            return true
        }
    }

    static func missingEssentials(in trip: Trip) -> [Suggestion] {
        trip.items.filter { $0.essential && !$0.packed }.map { Suggestion(title: $0.name, reason: "Essential, still unpacked", category: $0.category) }
    }
}
