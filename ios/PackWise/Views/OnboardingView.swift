import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @Query private var prefs: [UserPreference]
    @State private var step = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $step) {
                page(icon: "suitcase", title: "PackWise", subtitle: "A premium, on-device packing companion. Your trips live on your iPhone — private and offline-first.", tag: 0)
                page(icon: "viewfinder", title: "Scan with Vision", subtitle: "Import a photo. PackWise suggests items on device using Apple Vision. You approve every addition.", tag: 1)
                page(icon: "tshirt", title: "Plan every day", subtitle: "Build outfits from what you packed and see what is still missing before departure.", tag: 2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 420)

            Button {
                if step < 2 { withAnimation { step += 1 } }
                else { complete() }
            } label: {
                Text(step < 2 ? "Continue" : "Open PackWise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()

            Button("Skip", action: complete)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
    }

    private func page(icon: String, title: String, subtitle: String, tag: Int) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon).font(.system(size: 44, weight: .light)).foregroundStyle(.primary)
            Text(title).font(.title.bold())
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 32)
        }.tag(tag)
    }

    private func complete() {
        let p = prefs.first ?? UserPreference()
        if prefs.isEmpty { context.insert(p) }
        p.hasCompletedOnboarding = true
        try? context.save()
    }
}
