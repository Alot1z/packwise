import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var prefs: [UserPreference]
    @State private var selection: Tab = .dashboard

    enum Tab { case dashboard, trips, scanner, library, templates }

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

                    TemplatesRootView()
                        .tabItem { Label("Templates", systemImage: "doc.on.doc") }
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
                NavigationLink("Templates") { TemplateLibraryView() }
                NavigationLink("Reminders") { RemindersView() }
                NavigationLink("Settings") { SettingsView() }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("More")
        }
    }
}
