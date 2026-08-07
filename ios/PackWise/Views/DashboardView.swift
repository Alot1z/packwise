import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]

    var upcoming: [Trip] { Array(trips.filter { $0.status != .archived }.prefix(5)) }

    /// Quick stats for the header card.
    private var totalPacked: Int { trips.flatMap(\.items).filter(\.packed).count }
    private var totalItems: Int { trips.flatMap(\.items).count }
    private var totalEssentialsMissing: Int { trips.reduce(0) { $0 + $1.essentialsMissing } }

    var body: some View {
        NavigationStack {
            List {
                if trips.isEmpty {
                    Section {
                        ContentUnavailableView("Welcome to PackWise", systemImage: "suitcase", description: Text("Create your first trip to see progress, reminders, and recommendations here. All local, all offline."))
                    }
                } else {
                    Section {
                        HStack(spacing: 12) {
                            StatPill(value: "\(trips.count)", label: "Trips")
                            StatPill(value: "\(totalPacked)/\(totalItems)", label: "Packed")
                            StatPill(value: "\(totalEssentialsMissing)", label: "Essentials left", alert: totalEssentialsMissing > 0)
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 4, trailing: 0))
                        .listSectionSeparator(.hidden)
                    }

                    Section("Upcoming") {
                        ForEach(upcoming) { trip in
                            NavigationLink(value: trip) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(trip.title).font(.subheadline.weight(.medium))
                                        Text(trip.destination).font(.caption).foregroundStyle(.secondary)
                                        if trip.essentialsMissing > 0 {
                                            Label("\(trip.essentialsMissing) essentials still unpacked", systemImage: "exclamationmark.triangle.fill")
                                                .font(.caption2.weight(.semibold))
                                                .foregroundStyle(Color(red: 0.72, green: 0.36, blue: 0.0))
                                        }
                                    }
                                    Spacer()
                                    ProgressView(value: trip.progress)
                                        .frame(width: 44)
                                        .accessibilityLabel("\(trip.title) progress")
                                        .accessibilityValue("\(Int(trip.progress * 100)) percent")
                                    Text("\(Int(trip.progress*100))%").font(.caption2.monospaced()).foregroundStyle(.secondary)
                                        .accessibilityHidden(true)
                                }
                            }
                        }
                    }

                    Section("Packing progress") {
                        ForEach(trips.filter { !$0.items.isEmpty }.prefix(4)) { trip in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack { Text(trip.title).font(.caption.weight(.medium)); Spacer(); Text(trip.status.label).font(.caption2).foregroundStyle(.secondary) }
                                ProgressView(value: trip.progress)
                                    .accessibilityLabel("\(trip.title) progress")
                                    .accessibilityValue("\(Int(trip.progress * 100)) percent")
                                Text("\(trip.items.filter(\.packed).count)/\(trip.items.count) packed").font(.caption2).foregroundStyle(.secondary)
                                    .accessibilityHidden(true)
                            }
                            .padding(.vertical, 2)
                        }
                        if trips.allSatisfy(\.items.isEmpty) {
                            Text("Add items to any trip to see progress here.").font(.caption).foregroundStyle(.secondary)
                        }
                    }

                    // Local recommendations (no cloud)
                    Section("Recommendations — on device") {
                        let recs = upcoming.flatMap { RecommendationService.suggestions(for: $0).prefix(2) }
                        if recs.isEmpty {
                            Text("No suggestions yet. Add destination, dates, or activities to a trip.").font(.caption).foregroundStyle(.secondary)
                        } else {
                            ForEach(recs) { r in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(r.title).font(.caption.weight(.medium))
                                    Text("\(r.reason) · \(r.category)").font(.caption2).foregroundStyle(.secondary)
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("\(r.title), \(r.reason), \(r.category)")
                            }
                        }
                    }

                    Section("Missing essentials") {
                        let missing = trips.flatMap { RecommendationService.missingEssentials(in: $0).prefix(2) }
                        if missing.isEmpty {
                            Label("All essentials are packed — or none marked as essential yet.", systemImage: "checkmark.circle.fill")
                                .font(.caption).foregroundStyle(.secondary)
                        } else {
                            ForEach(missing) { m in
                                LabeledContent(m.title, value: m.category).font(.caption)
                            }
                        }
                    }

                    Section("Quick actions") {
                        NavigationLink("Create trip", value: "createTrip")
                        NavigationLink("Photo Scanner", value: "scanner")
                        NavigationLink("Search everything", value: "search")
                        NavigationLink("Templates", value: "templates")
                    }

                    Section("Recent activity") {
                        ForEach(trips.sorted(by: { $0.updatedAt > $1.updatedAt }).prefix(3)) { trip in
                            LabeledContent(trip.title, value: trip.updatedAt.formatted(date: .abbreviated, time: .shortened)).font(.caption)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Dashboard")
            .refreshable { /* local data — no network, but gives pull-to-refresh haptic */ }
            .navigationDestination(for: Trip.self) { TripDetailView(trip: $0) }
            .navigationDestination(for: String.self) { key in
                if key == "createTrip" { Text("Use Trips → New trip") }
                else if key == "templates" { TemplateLibraryView() }
                else if key == "scanner" { PhotoScannerView() }
                else if key == "search" { GlobalSearchView() }
            }
        }
    }
}

private struct StatPill: View {
    var value: String
    var label: String
    var alert: Bool = false
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.headline.monospacedDigit()).foregroundStyle(alert ? Color(red: 0.72, green: 0.36, blue: 0.0) : .primary)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(value) \(label)")
    }
}
