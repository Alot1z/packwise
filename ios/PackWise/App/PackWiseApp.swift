import SwiftUI
import SwiftData

@main
struct PackWiseApp: App {
    /// Shared container via App Group so Widgets and App Intents can read the
    /// same SwiftData store. Falls back to the default local store if App Groups
    /// are unavailable (e.g., unsigned simulator builds).
    private static let modelContainer: ModelContainer = {
        let schema = Schema([Trip.self, PackingItem.self, PersonalItem.self, Outfit.self, PackTemplate.self, PackCategory.self, Reminder.self, UserPreference.self])
        let groupConfig = ModelConfiguration(groupContainer: .identifier("group.com.packwise"))
        let fallbackConfig = ModelConfiguration()
        do {
            return try ModelContainer(for: schema, configurations: [groupConfig])
        } catch {
            // App Groups not available (unsigned builds, sim without entitlements).
            // The widget will not see data, but the app still works.
            return (try? ModelContainer(for: schema, configurations: [fallbackConfig])) ?? {
                try! ModelContainer(for: schema)
            }()
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(Self.modelContainer)
    }
}
