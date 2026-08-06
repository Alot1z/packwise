import Foundation
import SwiftData

@Model
final class Trip {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var destination: String
    var startDate: Date?
    var endDate: Date?
    var purpose: String?
    var status: TripStatus
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \PackingItem.trip) var items: [PackingItem] = []
    @Relationship(deleteRule: .cascade, inverse: \Outfit.trip) var outfits: [Outfit] = []

    init(title: String, destination: String, startDate: Date? = nil, endDate: Date? = nil, purpose: String? = nil, status: TripStatus = .planning) {
        self.title = title
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.purpose = purpose
        self.status = status
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var progress: Double {
        guard !items.isEmpty else { return 0 }
        return Double(items.filter(\.packed).count) / Double(items.count)
    }
}

enum TripStatus: String, Codable, CaseIterable, Identifiable {
    case planning, packing, ready, archived
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

@Model
final class PackingItem {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var category: String
    var quantity: Int
    var packed: Bool
    var essential: Bool
    var notes: String?
    var createdAt: Date
    var trip: Trip?

    init(name: String, category: String = "General", quantity: Int = 1, packed: Bool = false, essential: Bool = false, notes: String? = nil, trip: Trip? = nil) {
        self.name = name
        self.category = category
        self.quantity = quantity
        self.packed = packed
        self.essential = essential
        self.notes = notes
        self.createdAt = Date()
        self.trip = trip
    }
}

@Model
final class Outfit {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var dayLabel: String?
    var itemIDs: [UUID]
    var note: String?
    var createdAt: Date
    var trip: Trip?

    init(name: String, dayLabel: String? = nil, itemIDs: [UUID] = [], note: String? = nil, trip: Trip? = nil) {
        self.name = name
        self.dayLabel = dayLabel
        self.itemIDs = itemIDs
        self.note = note
        self.createdAt = Date()
        self.trip = trip
    }
}

@Model
final class PackTemplate {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var tag: String?
    var detail: String?
    var itemsJSON: Data
    var createdAt: Date

    init(name: String, tag: String? = nil, detail: String? = nil, items: [TemplateItem]) {
        self.name = name
        self.tag = tag
        self.detail = detail
        self.itemsJSON = (try? JSONEncoder().encode(items)) ?? Data()
        self.createdAt = Date()
    }

    var decodedItems: [TemplateItem] {
        (try? JSONDecoder().decode([TemplateItem].self, from: itemsJSON)) ?? []
    }
}

struct TemplateItem: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var category: String
    var quantity: Int
    var essential: Bool
}

let defaultCategories = ["General","Clothing","Shoes","Toiletries","Tech","Documents","Health","Other"]

let starterTemplates: [(name: String, tag: String, detail: String, items: [TemplateItem])] = [
    ("Weekend City · 2 Nights", "Weekend", "Compact city itinerary", [
        TemplateItem(name: "Linen shirt", category: "Clothing", quantity: 2, essential: true),
        TemplateItem(name: "Dark trousers", category: "Clothing", quantity: 1, essential: true),
        TemplateItem(name: "Sneakers", category: "Shoes", quantity: 1, essential: true),
        TemplateItem(name: "Toiletry kit", category: "Toiletries", quantity: 1, essential: true),
        TemplateItem(name: "Charger and cable", category: "Tech", quantity: 1, essential: true),
        TemplateItem(name: "Passport or ID", category: "Documents", quantity: 1, essential: true),
    ]),
    ("Business · Three Days", "Work", "Meetings and transit", [
        TemplateItem(name: "White shirt", category: "Clothing", quantity: 3, essential: true),
        TemplateItem(name: "Blazer", category: "Clothing", quantity: 1, essential: false),
        TemplateItem(name: "Dress shoes", category: "Shoes", quantity: 1, essential: true),
        TemplateItem(name: "Laptop and charger", category: "Tech", quantity: 1, essential: true),
        TemplateItem(name: "Notebook", category: "Documents", quantity: 1, essential: false),
    ]),
    ("Coastal Week", "Summer", "Light, breathable packing", [
        TemplateItem(name: "Swim shorts", category: "Clothing", quantity: 2, essential: true),
        TemplateItem(name: "Linen trousers", category: "Clothing", quantity: 1, essential: false),
        TemplateItem(name: "Sandals", category: "Shoes", quantity: 1, essential: true),
        TemplateItem(name: "Sunscreen", category: "Health", quantity: 1, essential: true),
        TemplateItem(name: "Sunglasses", category: "Other", quantity: 1, essential: false),
    ]),
]
