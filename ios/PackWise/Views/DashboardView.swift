import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]

    var upcoming: [Trip] { Array(trips.filter { $0.status != .archived }.prefix(5)) }

    private var totalPacked: Int { trips.flatMap(\.items).filter(\.packed).count }
    private var totalItems: Int { trips.flatMap(\.items).count }
    private var totalEssentialsMissing: Int { trips.reduce(0) { $0 + $1.essentialsMissing } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PackWiseDesign.Spacing.lg) {
                    if trips.isEmpty {
                        emptyState
                    } else {
                        statsRow
                        upcomingSection
                        progressSection
                        recommendationsSection
                        essentialsSection
                        quickActions
                        recentActivity
                    }
                }
                .padding(PackWiseDesign.Spacing.lg)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .refreshable { }
            .navigationDestination(for: Trip.self) { TripDetailView(trip: $0) }
            .navigationDestination(for: String.self) { key in
                switch key {
                case "templates": TemplateLibraryView()
                case "scanner": CameraScannerView()
                case "search": GlobalSearchView()
                default: Text("Navigate from the Trips tab")
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: PackWiseDesign.Spacing.xl) {
            Spacer().frame(height: 60)
            Image(systemName: "suitcase.fill")
                .font(.system(size: 56))
                .foregroundStyle(PackWiseDesign.Color.primaryLight)
            VStack(spacing: PackWiseDesign.Spacing.sm) {
                Text("Welcome to PackWise")
                    .font(PackWiseDesign.Typography.titleLarge)
                    .foregroundStyle(PackWiseDesign.Color.textPrimary)
                Text("Create your first trip to see progress,\nrecommendations, and packing intelligence here.\nAll local, all offline.")
                    .font(PackWiseDesign.Typography.body)
                    .foregroundStyle(PackWiseDesign.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            NavigationLink(value: "createTrip") {
                Label("Create your first trip", systemImage: "plus.circle.fill")
                    .font(PackWiseDesign.Typography.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(PackWiseDesign.Color.primary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: PackWiseDesign.Spacing.md) {
            StatPill(value: "\(trips.count)", label: "Trips", color: PackWiseDesign.Color.primary)
            StatPill(value: "\(totalPacked)/\(totalItems)", label: "Packed", color: PackWiseDesign.Color.secondary)
            StatPill(value: "\(totalEssentialsMissing)", label: "Essential", color: PackWiseDesign.Color.warning, alert: totalEssentialsMissing > 0)
        }
    }

    // MARK: - Upcoming Trips

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: PackWiseDesign.Spacing.md) {
            Text("Upcoming")
                .packWiseSectionHeader()
            ForEach(upcoming) { trip in
                NavigationLink(value: trip) {
                    upcomingCard(trip)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func upcomingCard(_ trip: Trip) -> some View {
        HStack(spacing: PackWiseDesign.Spacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.title)
                    .font(PackWiseDesign.Typography.headline)
                    .foregroundStyle(PackWiseDesign.Color.textPrimary)
                Text(trip.destination)
                    .font(PackWiseDesign.Typography.caption)
                    .foregroundStyle(PackWiseDesign.Color.textSecondary)
                if trip.essentialsMissing > 0 {
                    Label("\(trip.essentialsMissing) essentials unpacked", systemImage: "exclamationmark.triangle.fill")
                        .font(PackWiseDesign.Typography.caption2.weight(.semibold))
                        .foregroundStyle(PackWiseDesign.Color.warning)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                ProgressView(value: trip.progress)
                    .tint(trip.progress >= 1 ? PackWiseDesign.Color.success : PackWiseDesign.Color.primary)
                    .frame(width: 48)
                Text("\(Int(trip.progress * 100))%")
                    .font(PackWiseDesign.Typography.caption2)
                    .foregroundStyle(PackWiseDesign.Color.textTertiary)
            }
        }
        .packWiseCard()
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: PackWiseDesign.Spacing.md) {
            Text("Packing Progress")
                .packWiseSectionHeader()
            let active = trips.filter { !$0.items.isEmpty }.prefix(4)
            if active.isEmpty {
                Text("Add items to any trip to see progress here.")
                    .font(PackWiseDesign.Typography.caption)
                    .foregroundStyle(PackWiseDesign.Color.textTertiary)
            } else {
                VStack(spacing: PackWiseDesign.Spacing.md) {
                    ForEach(active) { trip in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(trip.title)
                                    .font(PackWiseDesign.Typography.captionBold)
                                    .foregroundStyle(PackWiseDesign.Color.textPrimary)
                                Spacer()
                                Text(trip.status.label)
                                    .font(PackWiseDesign.Typography.caption2)
                                    .packWiseChip(color: PackWiseDesign.Color.secondaryLight)
                            }
                            ProgressView(value: trip.progress)
                                .tint(PackWiseDesign.Color.accent)
                            Text("\(trip.progressLabel)")
                                .font(PackWiseDesign.Typography.caption2)
                                .foregroundStyle(PackWiseDesign.Color.textSecondary)
                        }
                    }
                }
                .packWiseCard()
            }
        }
    }

    // MARK: - Recommendations

    private var recommendationsSection: some View {
        let recs = upcoming.flatMap { RecommendationService.suggestions(for: $0).prefix(2) }
        guard !recs.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: PackWiseDesign.Spacing.md) {
                Text("Recommendations")
                    .packWiseSectionHeader()
                VStack(spacing: PackWiseDesign.Spacing.sm) {
                    ForEach(recs) { r in
                        HStack(spacing: PackWiseDesign.Spacing.md) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundStyle(PackWiseDesign.Color.accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(r.title)
                                    .font(PackWiseDesign.Typography.captionBold)
                                    .foregroundStyle(PackWiseDesign.Color.textPrimary)
                                Text("\(r.reason) · \(r.category)")
                                    .font(PackWiseDesign.Typography.caption2)
                                    .foregroundStyle(PackWiseDesign.Color.textSecondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
                .packWiseCard()
            }
        )
    }

    // MARK: - Essentials

    private var essentialsSection: some View {
        let missing = trips.flatMap { RecommendationService.missingEssentials(in: $0).prefix(2) }
        guard !missing.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: PackWiseDesign.Spacing.md) {
                Text("Missing Essentials")
                    .packWiseSectionHeader()
                VStack(spacing: PackWiseDesign.Spacing.sm) {
                    ForEach(missing) { m in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(PackWiseDesign.Color.warning)
                            Text(m.title)
                                .font(PackWiseDesign.Typography.caption)
                                .foregroundStyle(PackWiseDesign.Color.textPrimary)
                            Spacer()
                            Text(m.category)
                                .font(PackWiseDesign.Typography.caption2)
                                .packWiseChip(color: PackWiseDesign.Color.warning)
                        }
                    }
                }
                .packWiseCard()
            }
        )
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: PackWiseDesign.Spacing.md) {
            Text("Quick Actions")
                .packWiseSectionHeader()
            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: PackWiseDesign.Spacing.md) {
                QuickActionButton(icon: "viewfinder", title: "Scanner", destination: "scanner")
                QuickActionButton(icon: "square.grid.2x2", title: "Templates", destination: "templates")
                QuickActionButton(icon: "magnifyingglass", title: "Search", destination: "search")
                QuickActionButton(icon: "plus", title: "New Trip", destination: "createTrip")
            }
        }
    }

    // MARK: - Recent Activity

    private var recentActivity: some View {
        let recent = trips.sorted(by: { $0.updatedAt > $1.updatedAt }).prefix(3)
        guard !recent.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: PackWiseDesign.Spacing.md) {
                Text("Recent Activity")
                    .packWiseSectionHeader()
                VStack(spacing: PackWiseDesign.Spacing.sm) {
                    ForEach(recent) { trip in
                        HStack {
                            Text(trip.title)
                                .font(PackWiseDesign.Typography.caption)
                                .foregroundStyle(PackWiseDesign.Color.textPrimary)
                            Spacer()
                            Text(trip.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(PackWiseDesign.Typography.caption2)
                                .foregroundStyle(PackWiseDesign.Color.textTertiary)
                        }
                    }
                }
                .packWiseCard()
            }
        )
    }
}

// MARK: - Subviews

private struct StatPill: View {
    var value: String
    var label: String
    var color: Color
    var alert: Bool = false
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(alert ? color : PackWiseDesign.Color.textPrimary)
            Text(label)
                .font(PackWiseDesign.Typography.caption2)
                .foregroundStyle(PackWiseDesign.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: PackWiseDesign.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: PackWiseDesign.Radius.md)
                .strokeBorder(color.opacity(0.15), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(value) \(label)")
    }
}

private struct QuickActionButton: View {
    let icon: String
    let title: String
    let destination: String
    var body: some View {
        NavigationLink(value: destination) {
            VStack(spacing: PackWiseDesign.Spacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(PackWiseDesign.Color.primary)
                Text(title)
                    .font(PackWiseDesign.Typography.captionBold)
                    .foregroundStyle(PackWiseDesign.Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PackWiseDesign.Spacing.lg)
        }
        .buttonStyle(.plain)
        .packWiseCard()
    }
}
