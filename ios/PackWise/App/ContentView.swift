import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var prefs: [UserPreference]
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]
    @State private var selection: Tab = .dashboard
    @Environment(\.horizontalSizeClass) private var hSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum Tab: Hashable { case dashboard, trips, scanner, library, search, more }

    /// Count trips with essentials still unpacked — shown as a badge on Trips tab.
    private var tripsNeedingAttention: Int {
        trips.filter { $0.essentialsMissing > 0 && $0.status != .archived }.count
    }

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
                        .badge(tripsNeedingAttention > 0 ? tripsNeedingAttention : 0)
                        .tag(Tab.trips)

                    CameraScannerView()
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
                        .tag(Tab.more)
                }
                // iPad: sidebar-adaptable tab bar
                .tabViewStyle(.automatic)
                .tint(Color(.tintColor))
                .accessibilityLabel("Main navigation")
            }
        }
        // Reduced-motion users get an instant swap, no fade (accessibility).
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: prefs.first?.hasCompletedOnboarding)
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
                    NavigationLink("Outfits — open a trip to plan") {
                        Text("Open any trip → Outfits tab to create day-by-day outfits.").foregroundStyle(.secondary)
                    }
                }
                Section("System") {
                    NavigationLink("Reminders") { RemindersView() }
                    NavigationLink("Settings") { SettingsView() }
                }
                Section {
                    Text("PackWise · On device · Offline-first · No account required")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }
                .listSectionSeparator(.hidden)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("More")
        }
    }
}
