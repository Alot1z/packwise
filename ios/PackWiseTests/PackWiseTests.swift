import Testing
import SwiftData
import Foundation
@testable import PackWise

@Suite("PackWise — Models & Persistence")
struct PackWiseTests {

    private func container() throws -> ModelContainer {
        try ModelContainer(for: Trip.self, PackingItem.self, PersonalItem.self, Outfit.self, PackTemplate.self, PackCategory.self, Reminder.self, UserPreference.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }

    @Test("Trip progress computes")
    func tripProgress() throws {
        let t = Trip(title: "Test", destination: "Kyoto")
        t.items = [PackingItem(name: "A", packed: true), PackingItem(name: "B", packed: false)]
        #expect(t.progress == 0.5)
        #expect(t.missingCount == 1)
    }

    @Test("PackingItem persists in SwiftData")
    func persistence() throws {
        let c = try container()
        let ctx = ModelContext(c)
        let trip = Trip(title: "T", destination: "Lisbon")
        ctx.insert(trip)
        let item = PackingItem(name: "Linen shirt", category: "Clothing", trip: trip)
        ctx.insert(item)
        try ctx.save()
        let fetched = try ctx.fetch(FetchDescriptor<Trip>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.items.count == 1)
    }

    @Test("Template encodes and decodes")
    func templateRoundtrip() {
        let items = [TemplateItem(name: "Sneakers", category: "Clothing", quantity: 1, essential: true)]
        let t = PackTemplate(name: "Weekend", items: items)
        #expect(t.decodedItems.count == 1)
        #expect(t.decodedItems.first?.name == "Sneakers")
    }

    @Test("Duplicate trip copies items")
    func duplicate() throws {
        let c = try container()
        let ctx = ModelContext(c)
        let trip = Trip(title: "Original", destination: "Hudson")
        ctx.insert(trip)
        ctx.insert(PackingItem(name: "Boots", trip: trip))
        try ctx.save()
        let copy = Trip(title: trip.title + " (Copy)", destination: trip.destination)
        ctx.insert(copy)
        for it in trip.items { ctx.insert(PackingItem(name: it.name, category: it.category, trip: copy)) }
        try ctx.save()
        #expect(copy.items.count == 1)
    }

    @Test("Onboarding preference defaults")
    func prefs() {
        let p = UserPreference()
        #expect(p.hasCompletedOnboarding == false)
        #expect(p.hapticsEnabled == true)
    }

    @Test("Reminder creation")
    func reminder() {
        let r = Reminder(title: "Pack", fireDate: Date().addingTimeInterval(3600))
        #expect(r.isEnabled == true)
        #expect(!r.title.isEmpty)
    }
}

@Suite("PackWise — Weather-aware recommendations (deterministic, offline)")
struct WeatherRecommendationTests {

    private func snapshot(condition: String, temp: Double, days: [(Date, Double, Double, Double)]) -> WeatherSnapshot {
        WeatherSnapshot(
            temperatureC: temp,
            condition: condition,
            symbolName: "cloud",
            daily: days.map { WeatherSnapshot.WeatherDay(date: $0.0, highC: $0.1, lowC: $0.2, condition: condition, symbolName: "cloud", precipitationChance: $0.3) }
        )
    }

    @Test("Rain in the trip window adds umbrella + rain shell")
    func rainy() {
        let start = Calendar.current.startOfDay(for: Date())
        let end = start.addingTimeInterval(86400 * 2)
        let trip = Trip(title: "Wet", destination: "Lisbon", startDate: start, endDate: end)
        let weather = snapshot(condition: "Rain", temp: 15, days: [(start, 18, 12, 0.8), (start.addingTimeInterval(86400), 17, 11, 0.7), (start.addingTimeInterval(2 * 86400), 19, 13, 0.2)])
        let titles = RecommendationService.suggestions(for: trip, weather: weather).map(\.title)
        #expect(titles.contains("Umbrella"))
        #expect(titles.contains("Rain shell"))
    }

    @Test("Cold lows add warm layers + gloves")
    func cold() {
        let start = Calendar.current.startOfDay(for: Date())
        let end = start.addingTimeInterval(86400)
        let trip = Trip(title: "Cold", destination: "Oslo", startDate: start, endDate: end)
        let weather = snapshot(condition: "Snow", temp: -2, days: [(start, 2, -6, 0.9)])
        let titles = RecommendationService.suggestions(for: trip, weather: weather).map(\.title)
        #expect(titles.contains("Warm layers"))
        #expect(titles.contains("Gloves"))
    }

    @Test("Heat adds sun protection")
    func hot() {
        let trip = Trip(title: "Hot", destination: "Cancún")
        let weather = snapshot(condition: "Clear", temp: 31, days: [])
        let titles = RecommendationService.suggestions(for: trip, weather: weather).map(\.title)
        #expect(titles.contains("Sunscreen"))
        #expect(titles.contains("Sunglasses"))
    }

    @Test("Nil weather falls back to the text engine only")
    func fallback() {
        let trip = Trip(title: "Beach", destination: "Tenerife beach", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 5))
        let with = RecommendationService.suggestions(for: trip, weather: snapshot(condition: "Clear", temp: 25, days: [])).map(\.title)
        let without = RecommendationService.suggestions(for: trip, weather: nil).map(\.title)
        #expect(without.contains("Sunscreen")) // text engine still fires on "beach"
        #expect(with.count >= without.count)
    }

    @Test("Precipitation chance averages only days inside the trip window")
    func precipitationAverages() {
        let start = Calendar.current.startOfDay(for: Date())
        let days = [
            (start.addingTimeInterval(-86400), 1.0), // before trip — excluded
            (start, 0.5),
            (start.addingTimeInterval(86400), 1.0),
            (start.addingTimeInterval(2 * 86400), 0.0) // after trip — excluded
        ]
        let weather = WeatherSnapshot(
            temperatureC: 12, condition: "Cloudy", symbolName: "cloud",
            daily: days.map { WeatherSnapshot.WeatherDay(date: $0.0, highC: 15, lowC: 10, condition: "Cloudy", symbolName: "cloud", precipitationChance: $0.1) }
        )
        let chance = WeatherProvider.precipitationChance(in: weather, from: start, to: start.addingTimeInterval(86400))
        #expect(chance == 0.75)
    }
}

@Suite("PackWise — Outfit recommendations (deterministic, offline)")
struct OutfitRecommendationTests {

    private func snapshot(condition: String, temp: Double, precip: Double) -> WeatherSnapshot {
        let start = Calendar.current.startOfDay(for: Date())
        return WeatherSnapshot(
            temperatureC: temp,
            condition: condition,
            symbolName: "cloud",
            daily: [WeatherSnapshot.WeatherDay(date: start, highC: temp + 3, lowC: temp - 3, condition: condition, symbolName: "cloud", precipitationChance: precip)]
        )
    }

    @Test("Business trip suggests business outfits")
    func businessOutfit() {
        let trip = Trip(title: "Conference", destination: "London", purpose: "Business meetings", tripCategory: "Work")
        // Pack items the outfit engine will match.
        trip.items = [
            PackingItem(name: "Blazer", packed: true, trip: trip),
            PackingItem(name: "White shirt", packed: true, trip: trip),
            PackingItem(name: "Dark trousers", packed: true, trip: trip),
            PackingItem(name: "Dress shoes", packed: true, trip: trip),
            PackingItem(name: "Notebook", packed: true, trip: trip),
            PackingItem(name: "Linen shirt", packed: true, trip: trip),
            PackingItem(name: "Sneakers", packed: true, trip: trip),
        ]
        let outfits = RecommendationService.outfitSuggestions(for: trip, weather: nil)
        #expect(outfits.contains(where: { $0.name == "Business meeting" }))
        #expect(outfits.contains(where: { $0.name == "Business casual" }))
    }

    @Test("Beach destination suggests beach outfits")
    func beachOutfit() {
        let trip = Trip(title: "Holiday", destination: "Miami beach", tripCategory: "Beach")
        trip.items = [
            PackingItem(name: "Swim shorts", packed: true, trip: trip),
            PackingItem(name: "Linen shirt", packed: true, trip: trip),
            PackingItem(name: "Sandals", packed: true, trip: trip),
            PackingItem(name: "Sunglasses", packed: true, trip: trip),
            PackingItem(name: "Linen trousers", packed: true, trip: trip),
            PackingItem(name: "Sneakers", packed: true, trip: trip),
        ]
        let outfits = RecommendationService.outfitSuggestions(for: trip, weather: nil)
        #expect(outfits.contains(where: { $0.name == "Beach afternoon" }))
    }

    @Test("Outdoor trip with rain risk suggests rain-ready outfit")
    func rainyOutdoorOutfit() {
        let trip = Trip(title: "Hike", destination: "trail", startDate: Date(), endDate: Date().addingTimeInterval(86400), activities: "hiking")
        trip.items = [
            PackingItem(name: "Hiking boots", packed: true, trip: trip),
            PackingItem(name: "Rain shell", packed: true, trip: trip),
            PackingItem(name: "Water bottle", packed: true, trip: trip),
            PackingItem(name: "Headlamp", packed: true, trip: trip),
            PackingItem(name: "Waterproof bag", packed: true, trip: trip),
        ]
        let weather = snapshot(condition: "Rain", temp: 12, precip: 0.8)
        let outfits = RecommendationService.outfitSuggestions(for: trip, weather: weather)
        #expect(outfits.contains(where: { $0.name == "Trail day" }))
        #expect(outfits.contains(where: { $0.name == "Wet trail" }))
    }

    @Test("International trip suggests travel day outfit")
    func internationalOutfit() {
        let trip = Trip(title: "Euro Trip", destination: "Paris", tripCategory: "International")
        trip.items = [
            PackingItem(name: "Sneakers", packed: true, trip: trip),
            PackingItem(name: "Linen shirt", packed: true, trip: trip),
            PackingItem(name: "Dark trousers", packed: true, trip: trip),
            PackingItem(name: "Passport", packed: true, trip: trip),
        ]
        let outfits = RecommendationService.outfitSuggestions(for: trip, weather: nil)
        #expect(outfits.contains(where: { $0.name == "Travel day" }))
    }

    @Test("Outfit suggestions filter out items that are not packed")
    func filtersUnpackedItems() {
        let trip = Trip(title: "Weekend", destination: "Berlin", tripCategory: "International")
        // Only pack 2 out of 4 items needed for "Travel day".
        trip.items = [
            PackingItem(name: "Sneakers", packed: true, trip: trip),
            PackingItem(name: "Linen shirt", packed: true, trip: trip),
            PackingItem(name: "Dark trousers", packed: false, trip: trip), // not packed
            PackingItem(name: "Passport", packed: false, trip: trip),       // not packed
        ]
        let outfits = RecommendationService.outfitSuggestions(for: trip, weather: nil)
        // "Travel day" should be filtered out because 2 of its 4 items are unpacked.
        #expect(!outfits.contains(where: { $0.name == "Travel day" }))
    }
}
