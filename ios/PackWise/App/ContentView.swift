import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]
    @State private var selectedTrip: Trip?
    @State private var selection: Tab = .trips

    enum Tab { case trips, templates, settings }

    var body: some View {
        TabView(selection: $selection) {
            TripListView(selectedTrip: $selectedTrip)
                .tabItem { Label("Trips", systemImage: "suitcase") }
                .tag(Tab.trips)

            TemplateLibraryView()
                .tabItem { Label("Templates", systemImage: "doc.on.doc") }
                .tag(Tab.templates)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
    }
}
