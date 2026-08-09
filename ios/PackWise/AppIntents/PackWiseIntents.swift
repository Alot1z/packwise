import Foundation
import AppIntents
import SwiftData

// MARK: - App Shortcuts Provider

/// Registers PackWise shortcuts with Siri, Spotlight, and the Shortcuts app.
/// No separate extension target needed — App Intents live in the main app.
@available(iOS 17.0, *)
struct PackWiseShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddInventoryItemIntent(),
            phrases: [
                "Add an item to my inventory in ${applicationName}",
                "Add an item to my packing list in ${applicationName}",
                "Add a new item in ${applicationName}"
            ],
            shortTitle: "Add Item",
            systemImageName: "plus.circle"
        )
        AppShortcut(
            intent: MarkPackedIntent(),
            phrases: [
                "Mark an item as packed in ${applicationName}",
                "Mark an item as packed for my trip in ${applicationName}",
                "Check off an item in ${applicationName}"
            ],
            shortTitle: "Mark Packed",
            systemImageName: "checkmark.circle"
        )
        AppShortcut(
            intent: CreateTripIntent(),
            phrases: [
                "Create a trip in ${applicationName}",
                "Plan a trip in ${applicationName}",
                "Make a new trip in ${applicationName}"
            ],
            shortTitle: "New Trip",
            systemImageName: "airplane"
        )
    }
}

// MARK: - Add Inventory Item Intent

@available(iOS 17.0, *)
struct AddInventoryItemIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Inventory Item"
    static let description = IntentDescription("Add an item to your personal inventory library.", categoryName: "Inventory")

    @Parameter(title: "Item Name", description: "The name of the item to add.")
    var itemName: String

    @Parameter(title: "Category", description: "The category for the item.", default: "General")
    var categoryName: String

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$itemName) to inventory") {
            \.$categoryName
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let schema = Schema([PersonalItem.self])
        let groupConfig = ModelConfiguration(groupContainer: .identifier("group.com.packwise"))
        guard let container = try? ModelContainer(for: schema, configurations: [groupConfig]) else {
            return .result(dialog: "Could not access your inventory.")
        }
        let context = container.mainContext
        let item = PersonalItem(name: itemName, category: categoryName)
        context.insert(item)
        try context.save()
        return .result(dialog: "Added \(itemName) to your inventory.")
    }
}

// MARK: - Mark Packed Intent

@available(iOS 17.0, *)
struct MarkPackedIntent: AppIntent {
    static let title: LocalizedStringResource = "Mark Item Packed"
    static let description = IntentDescription("Mark a packing item as packed for your trip.", categoryName: "Packing")

    @Parameter(title: "Item Name", description: "The name of the item to mark as packed.")
    var itemName: String

    static var parameterSummary: some ParameterSummary {
        Summary("Mark \(\.$itemName) as packed")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let schema = Schema([PackingItem.self, Trip.self])
        let groupConfig = ModelConfiguration(groupContainer: .identifier("group.com.packwise"))
        guard let container = try? ModelContainer(for: schema, configurations: [groupConfig]) else {
            return .result(dialog: "Could not access your packing list.")
        }
        let context = container.mainContext

        let descriptor = FetchDescriptor<PackingItem>(
            predicate: #Predicate { $0.name.localizedStandardContains(itemName) && !$0.packed }
        )
        let matches = try context.fetch(descriptor)
        guard let first = matches.first else {
            return .result(dialog: "Could not find an unpacked item named \(itemName).")
        }
        first.packed = true
        try context.save()
        return .result(dialog: "Marked \(first.name) as packed.")
    }
}

// MARK: - Create Trip Intent

@available(iOS 17.0, *)
struct CreateTripIntent: AppIntent {
    static let title: LocalizedStringResource = "Create Trip"
    static let description = IntentDescription("Create a new trip with a destination.", categoryName: "Trips")

    @Parameter(title: "Trip Title", description: "A name for the trip.")
    var tripTitle: String

    @Parameter(title: "Destination", description: "Where you are going.")
    var destination: String

    @Parameter(title: "Start Date", description: "When the trip begins.", default: nil)
    var startDate: Date?

    static var parameterSummary: some ParameterSummary {
        Summary("Create trip \(\.$tripTitle) to \(\.$destination)") {
            \.$startDate
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let schema = Schema([Trip.self])
        let groupConfig = ModelConfiguration(groupContainer: .identifier("group.com.packwise"))
        guard let container = try? ModelContainer(for: schema, configurations: [groupConfig]) else {
            return .result(dialog: "Could not create your trip.")
        }
        let context = container.mainContext
        let trip = Trip(title: tripTitle, destination: destination, startDate: startDate)
        context.insert(trip)
        try context.save()
        if let date = startDate {
            return .result(dialog: "Created trip to \(destination) starting \(date.formatted(date: .abbreviated, time: .omitted)).")
        }
        return .result(dialog: "Created trip to \(destination).")
    }
}
