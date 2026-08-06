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
