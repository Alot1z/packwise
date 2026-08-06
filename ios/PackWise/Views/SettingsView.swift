import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("PackWise") {
                    LabeledContent("Version", value: "1.0.0 (1)")
                    LabeledContent("Storage", value: "On device · SwiftData")
                    LabeledContent("Network", value: "Offline-first · No required APIs")
                }
                Section("Privacy") {
                    Text("PackWise stores trips, packing lists, items, outfits, templates, photos, notes, and progress directly on your iPhone. No mandatory login, no paid services, and no cloud dependency for the core experience.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Section("Support") {
                    Link("View web companion", destination: URL(string: "https://example.com")!)
                    Text("All portable via local export (JSON). Your data remains yours.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
    }
}
