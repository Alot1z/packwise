import SwiftUI
import SwiftData

@main
struct PackWiseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Trip.self, PackingItem.self, Outfit.self, PackTemplate.self])
                .tint(Color("AccentColor"))
        }
    }
}
