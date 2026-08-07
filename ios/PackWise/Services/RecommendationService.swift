import Foundation

/// Local, rule-based recommendations. No network, no cloud model.
enum RecommendationService {
    struct Suggestion: Identifiable {
        let id = UUID()
        let title: String
        let reason: String
        let category: String
    }

    static func suggestions(for trip: Trip) -> [Suggestion] {
        var out: [Suggestion] = []
        let dest = (trip.destination + " " + (trip.purpose ?? "") + " " + (trip.activities ?? "")).lowercased()
        // Inclusive day count: Jan 1 → Jan 3 is 3 days of travel.
        let days: Int = {
            guard let s = trip.startDate, let e = trip.endDate else { return 0 }
            let day = Calendar.current.dateComponents([.day], from: s, to: e).day ?? 0
            return max(1, day + 1)
        }()

        if dest.contains("beach") || dest.contains("coast") || dest.contains("tropical") {
            out.append(Suggestion(title: "Sunscreen", reason: "Destination suggests sun exposure", category: "Medical"))
            out.append(Suggestion(title: "Sunglasses", reason: "Bright conditions", category: "Accessories"))
        }
        if dest.contains("hiking") || dest.contains("trail") || dest.contains("mountain") {
            out.append(Suggestion(title: "Hiking boots", reason: "Activities include outdoors", category: "Outdoor"))
            out.append(Suggestion(title: "Rain shell", reason: "Weather variability", category: "Outdoor"))
        }
        if dest.contains("business") || dest.contains("meeting") || dest.contains("conference") {
            out.append(Suggestion(title: "Blazer", reason: "Business context", category: "Clothing"))
        }
        if days >= 4 {
            out.append(Suggestion(title: "Laundry kit", reason: "Trip length \(days) days", category: "Toiletries"))
        }
        // International heuristic
        if dest.contains("international") || dest.contains("japan") || dest.contains("europe") || trip.tripCategory == "International" {
            out.append(Suggestion(title: "Power adapter", reason: "International travel", category: "Electronics"))
            out.append(Suggestion(title: "Passport", reason: "International travel", category: "Documents"))
        }

        // Dedupe against existing items
        let existing = Set(trip.items.map { $0.name.lowercased() })
        return out.filter { !existing.contains($0.title.lowercased()) }
    }

    static func missingEssentials(in trip: Trip) -> [Suggestion] {
        trip.items.filter { $0.essential && !$0.packed }.map { Suggestion(title: $0.name, reason: "Essential, still unpacked", category: $0.category) }
    }
}
