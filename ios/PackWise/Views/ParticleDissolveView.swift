import SwiftUI
import UIKit

/// FullPack-style "background dissolves into particles" moment shown right
/// after capture while on-device subject extraction finishes.
///
/// The captured photo sits dimmed beneath a burst of particles that fly
/// outward and fade; when the transparent cutout arrives it scales in on top.
/// The view is self-contained: it plays once and calls `onComplete` when done
/// (or immediately when Reduce Motion is on, as a simple crossfade).
///
/// Swift 6 notes: all state is MainActor-isolated view state; particles are
/// immutable value structs generated once at appear, so nothing is shared
/// across isolation domains. The completion timer is a `.task` that cancels
/// with the view.
struct ParticleDissolveView: View {
    let sourceImage: UIImage
    let isolatedImage: UIImage?
    let onComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var burst = false
    @State private var particles: [Particle] = []

    private struct Particle: Identifiable {
        let id: Int
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let targetOpacity: Double
        let delay: Double
        let duration: Double
        let rotation: Double
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Original photo, dimmed — the surface being dissolved away.
            Image(uiImage: sourceImage)
                .resizable()
                .scaledToFit()
                .opacity(reduceMotion ? 0 : (burst ? 0.12 : 0.55))
                .scaleEffect(reduceMotion ? 1.05 : (burst ? 1.06 : 1.0))
                .accessibilityHidden(true)

            // The transparent cutout lands on top as the background dissolves.
            if let isolated = isolatedImage {
                Image(uiImage: isolated)
                    .resizable()
                    .scaledToFit()
                    .opacity(burst ? 1 : 0)
                    .scaleEffect(burst ? 1 : 0.82)
                    .accessibilityLabel("Item with background removed")
                    .accessibilityAddTraits(.isImage)
            }

            // Particle burst.
            if !reduceMotion {
                ForEach(particles) { p in
                    RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                        .fill(.white.opacity(burst ? 0 : p.targetOpacity))
                        .frame(width: p.size, height: p.size)
                        .rotationEffect(.degrees(burst ? p.rotation : 0))
                        .offset(x: burst ? p.x : 0, y: burst ? p.y : 0)
                        .animation(.easeOut(duration: p.duration).delay(p.delay), value: burst)
                        .accessibilityHidden(true)
                }
                .allowsHitTesting(false)
            }
        }
        .onAppear(perform: start)
        .task {
            // Hold the moment long enough to read, then hand off.
            let hold: UInt64 = reduceMotion ? 450_000_000 : 1_250_000_000
            try? await Task.sleep(nanoseconds: hold)
            guard !Task.isCancelled else { return }
            onComplete()
        }
        .accessibilityElement(children: .contain)
    }

    private func start() {
        guard !reduceMotion else { return }
        particles = Self.makeParticles(count: 64)
        withAnimation(PackWiseDesign.Animation.standard) {
            burst = true
        }
    }

    /// 64 particles, seeded for a stable, repeatable burst.
    private static func makeParticles(count: Int) -> [Particle] {
        var rng = SeededGenerator(seed: 0x5EED)
        return (0..<count).map { i in
            let angle = Double(i) / Double(count) * 2 * .pi + Double.random(in: -0.12...0.12, using: &rng)
            let radius = CGFloat.random(in: 90...320, using: &rng)
            return Particle(
                id: i,
                x: CGFloat(cos(angle)) * radius,
                y: CGFloat(sin(angle)) * radius,
                size: CGFloat.random(in: 2...7, using: &rng),
                targetOpacity: Double.random(in: 0.35...0.9, using: &rng),
                delay: Double.random(in: 0...0.28, using: &rng),
                duration: Double.random(in: 0.55...0.95, using: &rng),
                rotation: Double.random(in: -720...720, using: &rng)
            )
        }
    }
}

/// Tiny deterministic RNG (SplitMix64) so the dissolve looks identical every run.
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
