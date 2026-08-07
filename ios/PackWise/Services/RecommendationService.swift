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

    static func suggestions(for trip: Trip) -> [Suggestion] {
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
