import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var prefs: [UserPreference]
    @State private var selection: Tab = .dashboard

    enum Tab { case dashboard, trips, scanner, library, templates, search }

    var body: some View {
        Group {
            if prefs.first?.hasCompletedOnboarding != true {
                OnboardingView()
            } else {
                TabView(selection: $selection) {
                    DashboardView()
                        .tabItem { Label("Dashboard", systemImage: "rectangle.grid.2x2") }
                        .tag(Tab.dashboard)

                    TripsRootView()
                        .tabItem { Label("Trips", systemImage: "suitcase") }
                        .tag(Tab.trips)

                    PhotoScannerView()
                        .tabItem { Label("Scanner", systemImage: "viewfinder") }
                        .tag(Tab.scanner)

                    LibraryView()
                        .tabItem { Label("Library", systemImage: "shippingbox") }
                        .tag(Tab.library)

                    GlobalSearchView()
                        .tabItem { Label("Search", systemImage: "magnifyingglass") }
                        .tag(Tab.search)

                    TemplatesRootView()
                        .tabItem { Label("More", systemImage: "ellipsis.circle") }
                        .tag(Tab.templates)
                }
            }
        }
    }
}

private struct TripsRootView: View {
    @State private var selected: Trip?
    var body: some View { TripListView(selectedTrip: $selected) }
}

private struct TemplatesRootView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Plan") {
                    NavigationLink("Templates") { TemplateLibraryView() }
                    NavigationLink("Outfits — open a trip to plan") { Text("Open any trip → Outfits tab to create day-by-day outfits.").foregroundStyle(.secondary) }
                }
                Section("System") {
                    NavigationLink("Reminders") { RemindersView() }
                    NavigationLink("Settings") { SettingsView() }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("More")
        }
    }
}
