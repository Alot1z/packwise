import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var prefs: [UserPreference]
    @Environment(\.modelContext) private var context
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section("PackWise") {
                    LabeledContent("Version", value: "1.0.0 (1)")
                    LabeledContent("Storage", value: "On device · SwiftData")
                    LabeledContent("Network", value: "Offline-first")
                }
                Section("Preferences") {
                    if let p = prefs.first {
                        Toggle("Haptics", isOn: Binding(get: { p.hapticsEnabled }, set: { p.hapticsEnabled = $0; try? context.save() }))
                        Button(p.hasCompletedOnboarding ? "Replay onboarding" : "Onboarding: pending") {
                            p.hasCompletedOnboarding = false; try? context.save()
                        }
                    } else {
                        Button("Enable onboarding") {
                            let p = UserPreference(); p.hasCompletedOnboarding = false; context.insert(p); try? context.save()
                        }
                    }
                }
                Section("Accessibility") {
                    Text("Supports Light and Dark Mode, Dynamic Type, and VoiceOver. Layouts adapt for iPhone and iPad.").font(.caption).foregroundStyle(.secondary)
                    Text("Test with: Settings → Accessibility → Display & Text Size / VoiceOver.").font(.caption2).foregroundStyle(.secondary)
                }
                Section("Privacy") {
                    Text("PackWise stores trips, packing lists, items, outfits, templates, library, photos, notes, and progress directly on your iPhone via SwiftData. No mandatory login, no paid services, and no cloud dependency for the core experience. Vision processing is on device.").font(.caption).foregroundStyle(.secondary)
                }
                Section("Data") {
                    Button("Reset onboarding flag", role: .destructive) { showResetConfirm = true }
                    Text("To erase all data: delete the app, or remove trips individually. SwiftData is backup-safe and migrates automatically.").font(.caption).foregroundStyle(.secondary)
                }
                Section("Build") {
                    Text("Xcode project: ios/PackWise.xcodeproj (generated via XcodeGen). Build locally: ios/build.sh. CI: .github/workflows/ios.yml produces an unsigned IPA for AltStore/Sideloadly.").font(.caption).foregroundStyle(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .alert("Reset onboarding?", isPresented: $showResetConfirm) {
                Button("Reset", role: .destructive) { prefs.first?.hasCompletedOnboarding = false; try? context.save() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
