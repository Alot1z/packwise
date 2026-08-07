import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var prefs: [UserPreference]
    @Environment(\.modelContext) private var context
    @State private var showResetConfirm = false

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section("PackWise") {
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Storage", value: "On device · SwiftData")
                    LabeledContent("Network", value: "Offline-first")
                    LabeledContent("iOS", value: "17.0+ · iPhone + iPad")
                }
                Section("Preferences") {
                    if let p = prefs.first {
                        Toggle("Haptics", isOn: Binding(get: { p.hapticsEnabled }, set: { p.hapticsEnabled = $0; try? context.save() }))
                            .accessibilityLabel("Haptic feedback")
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
                    Label("Supports Light and Dark Mode, Dynamic Type, and VoiceOver. Layouts adapt for iPhone and iPad.", systemImage: "accessibility")
                        .font(.caption).foregroundStyle(.secondary)
                    Text("Test with: Settings → Accessibility → Display & Text Size / VoiceOver / Motion → Reduce Motion.").font(.caption2).foregroundStyle(.secondary)
                }
                Section("Privacy") {
                    Label("PackWise stores trips, packing lists, items, outfits, templates, library, photos, notes, and progress directly on your iPhone via SwiftData. No mandatory login, no paid services, and no cloud dependency for the core experience. Vision processing is on device.", systemImage: "lock.shield")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Section("Data") {
                    Button("Reset onboarding flag", role: .destructive) { showResetConfirm = true }
                    Text("To erase all data: delete the app, or remove trips individually. SwiftData is backup-safe and migrates automatically.").font(.caption).foregroundStyle(.secondary)
                }
                Section("Build") {
                    Text("Xcode project: ios/PackWise.xcodeproj (generated via XcodeGen). Build locally: ios/build.sh. CI: .github/workflows/ios.yml produces an unsigned IPA for AltStore/Sideloadly.").font(.caption).foregroundStyle(.secondary)
                    Link("Open project on GitHub", destination: URL(string: "https://github.com/Alot1z/packwise")!)
                        .font(.caption)
                }
                Section {
                    Text("MIT license · No tracking · Art is code (assets/*.svg) · Made with SwiftUI + SwiftData + Vision.")
                        .font(.caption2).foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }
                .listSectionSeparator(.hidden)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .alert("Reset onboarding?", isPresented: $showResetConfirm) {
                Button("Reset", role: .destructive) { prefs.first?.hasCompletedOnboarding = false; try? context.save() }
                Button("Cancel", role: .cancel) {}
            } message: { Text("You will see the onboarding pages again on next launch.") }
        }
    }
}
