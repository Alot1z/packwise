import SwiftUI
import SwiftData

@main
struct PackWiseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Trip.self, PackingItem.self, PersonalItem.self, Outfit.self, PackTemplate.self, PackCategory.self, Reminder.self, UserPreference.self])
        }
    }
}
