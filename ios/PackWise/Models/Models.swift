import Foundation
import SwiftData

// MARK: - Trip

@Model
final class Trip {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var destination: String
    /// Optional resolved destination coordinate (MapKit / geocoding).
    /// Used by the weather-aware packing suggestions.
    var destinationLatitude: Double?
    var destinationLongitude: Double?
    var startDate: Date?
    var endDate: Date?
    var purpose: String?
    var activities: String?
    var climateInfo: String?
    var notes: String?
    var tripCategory: String?
    var status: TripStatus
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \PackingItem.trip) var items: [PackingItem] = []
    @Relationship(deleteRule: .cascade, inverse: \Outfit.trip) var outfits: [Outfit] = []
    @Relationship(deleteRule: .cascade, inverse: \Reminder.trip) var reminders: [Reminder] = []

    init(title: String, destination: String, destinationLatitude: Double? = nil, destinationLongitude: Double? = nil, startDate: Date? = nil, endDate: Date? = nil, purpose: String? = nil, activities: String? = nil, climateInfo: String? = nil, notes: String? = nil, tripCategory: String? = nil, status: TripStatus = .planning) {
        self.title = title
        self.destination = destination
        self.destinationLatitude = destinationLatitude
        self.destinationLongitude = destinationLongitude
        self.startDate = startDate
        self.endDate = endDate
        self.purpose = purpose
        self.activities = activities
        self.climateInfo = climateInfo
        self.notes = notes
        self.tripCategory = tripCategory
        self.status = status
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var progress: Double {
        guard !items.isEmpty else { return 0 }
        return Double(items.filter(\.packed).count) / Double(items.count)
    }
    var missingCount: Int { items.filter { !$0.packed }.count }
    var essentialsMissing: Int { items.filter { $0.essential && !$0.packed }.count }
    /// Human-readable progress, e.g. "3 of 8 packed · 38%"
    var progressLabel: String { "\(items.filter(\.packed).count) of \(items.count) packed · \(Int(progress * 100))%" }
    /// Days until departure, nil if no start date.
    var daysUntilDeparture: Int? {
        guard let s = startDate else { return nil }
        let d = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: s)).day
        return d
    }
    /// Whether the trip is in the past.
    var isPast: Bool {
        guard let e = endDate else { return false }
        return e < Calendar.current.startOfDay(for: Date())
    }
}

enum TripStatus: String, Codable, CaseIterable, Identifiable {
    case planning, packing, ready, archived
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

// MARK: - PackingItem

@Model
final class PackingItem {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var category: String
    var quantity: Int
    var packed: Bool
    var essential: Bool
    var notes: String?
    var photoData: Data?
    var isFavorite: Bool = false
    var createdAt: Date
    var trip: Trip?
    /// Optional link to PersonalItem library entry
    var personalItemID: UUID?

    init(name: String, category: String = "General", quantity: Int = 1, packed: Bool = false, essential: Bool = false, notes: String? = nil, photoData: Data? = nil, personalItemID: UUID? = nil, trip: Trip? = nil) {
        self.name = name
        self.category = category
        self.quantity = quantity
        self.packed = packed
        self.essential = essential
        self.notes = notes
        self.photoData = photoData
        self.personalItemID = personalItemID
        self.createdAt = Date()
        self.trip = trip
    }
}

// MARK: - Personal Item Library (reusable across trips)

@Model
final class PersonalItem {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var category: String
    var notes: String?
    var photoData: Data?
    var isFavorite: Bool
    var createdAt: Date

    init(name: String, category: String = "General", notes: String? = nil, photoData: Data? = nil, isFavorite: Bool = false) {
        self.name = name
        self.category = category
        self.notes = notes
        self.photoData = photoData
        self.isFavorite = isFavorite
        self.createdAt = Date()
    }
}

// MARK: - Outfit

@Model
final class Outfit {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var dayLabel: String?
    var itemIDs: [UUID]
    var note: String?
    var isFavorite: Bool
    var createdAt: Date
    var trip: Trip?

    init(name: String, dayLabel: String? = nil, itemIDs: [UUID] = [], note: String? = nil, isFavorite: Bool = false, trip: Trip? = nil) {
        self.name = name
        self.dayLabel = dayLabel
        self.itemIDs = itemIDs
        self.note = note
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.trip = trip
    }
}

// MARK: - Category (user-defined)

@Model
final class PackCategory {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var icon: String
    var isBuiltIn: Bool
    var sortOrder: Int

    init(name: String, icon: String = "tag", isBuiltIn: Bool = false, sortOrder: Int = 0) {
        self.name = name
        self.icon = icon
        self.isBuiltIn = isBuiltIn
        self.sortOrder = sortOrder
    }
}

// MARK: - Reminder

@Model
final class Reminder {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var fireDate: Date
    var isEnabled: Bool
    var trip: Trip?
    var createdAt: Date

    init(title: String, fireDate: Date, isEnabled: Bool = true, trip: Trip? = nil) {
        self.title = title
        self.fireDate = fireDate
        self.isEnabled = isEnabled
        self.trip = trip
        self.createdAt = Date()
    }
}

// MARK: - UserPreference

@Model
final class UserPreference {
    @Attribute(.unique) var id: UUID = UUID()
    // Single row: fetch first
    var hasCompletedOnboarding: Bool = false
    var defaultTripCategory: String?
    var hapticsEnabled: Bool = true
    var accentName: String = "PackWiseAccent"

    init() {}
}

// MARK: - Template

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

// MARK: - Constants

let defaultCategories: [(name: String, icon: String)] = [
    ("Clothing", "tshirt"), ("Electronics", "cpu"), ("Toiletries", "drop"),
    ("Documents", "doc.text"), ("Medical", "cross.case"), ("Accessories", "eyeglasses"),
    ("Outdoor", "mountain.2"), ("General", "shippingbox")
]

let builtInCategoryNames = ["Clothing","Electronics","Toiletries","Documents","Medical","Accessories","Outdoor","General"]

let starterTemplates: [(name: String, tag: String, detail: String, items: [TemplateItem])] = [
    ("Weekend City · 2 Nights", "Weekend", "Compact city itinerary", [
        TemplateItem(name: "Linen shirt", category: "Clothing", quantity: 2, essential: true),
        TemplateItem(name: "Dark trousers", category: "Clothing", quantity: 1, essential: true),
        TemplateItem(name: "Sneakers", category: "Clothing", quantity: 1, essential: true),
        TemplateItem(name: "Toiletry kit", category: "Toiletries", quantity: 1, essential: true),
        TemplateItem(name: "Charger and cable", category: "Electronics", quantity: 1, essential: true),
        TemplateItem(name: "Passport or ID", category: "Documents", quantity: 1, essential: true),
    ]),
    ("Business · Three Days", "Work", "Meetings and transit", [
        TemplateItem(name: "White shirt", category: "Clothing", quantity: 3, essential: true),
        TemplateItem(name: "Blazer", category: "Clothing", quantity: 1, essential: false),
        TemplateItem(name: "Dress shoes", category: "Clothing", quantity: 1, essential: true),
        TemplateItem(name: "Laptop and charger", category: "Electronics", quantity: 1, essential: true),
        TemplateItem(name: "Notebook", category: "Documents", quantity: 1, essential: false),
    ]),
    ("Beach Vacation", "Beach", "Sun and sea", [
        TemplateItem(name: "Swim shorts", category: "Clothing", quantity: 2, essential: true),
        TemplateItem(name: "Linen trousers", category: "Clothing", quantity: 1, essential: false),
        TemplateItem(name: "Sandals", category: "Accessories", quantity: 1, essential: true),
        TemplateItem(name: "Sunscreen", category: "Medical", quantity: 1, essential: true),
        TemplateItem(name: "Sunglasses", category: "Accessories", quantity: 1, essential: false),
    ]),
    ("Hiking Trip", "Outdoor", "Trails and weather-ready", [
        TemplateItem(name: "Hiking boots", category: "Outdoor", quantity: 1, essential: true),
        TemplateItem(name: "Rain shell", category: "Outdoor", quantity: 1, essential: true),
        TemplateItem(name: "Water bottle", category: "Outdoor", quantity: 1, essential: true),
        TemplateItem(name: "First-aid kit", category: "Medical", quantity: 1, essential: true),
        TemplateItem(name: "Headlamp", category: "Electronics", quantity: 1, essential: false),
    ]),
    ("International Travel", "International", "Documents and adapters", [
        TemplateItem(name: "Passport", category: "Documents", quantity: 1, essential: true),
        TemplateItem(name: "Power adapter", category: "Electronics", quantity: 1, essential: true),
        TemplateItem(name: "Toiletry kit", category: "Toiletries", quantity: 1, essential: true),
        TemplateItem(name: "Medications", category: "Medical", quantity: 1, essential: true),
        TemplateItem(name: "Travel pillow", category: "Accessories", quantity: 1, essential: false),
    ]),
]
