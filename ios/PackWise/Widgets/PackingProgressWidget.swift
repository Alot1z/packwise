import SwiftUI
import WidgetKit
import SwiftData

// MARK: - Packing Progress Widget

/// Shows packing progress across all active trips.

struct PackingProgressWidget: Widget {
    let kind: String = "com.packwise.widget.progress"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProgressProvider()) { entry in
            PackingProgressWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Packing Progress")
        .description("See packing progress across your upcoming trips.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Timeline Entry

struct ProgressEntry: TimelineEntry {
    let date: Date
    let trips: [TripSummary]
}

struct TripSummary {
    let title: String
    let destination: String
    let packedCount: Int
    let totalCount: Int
    let progress: Double
    let daysUntilDeparture: Int?
}

// MARK: - Timeline Provider

struct ProgressProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProgressEntry {
        ProgressEntry(
            date: Date(),
            trips: [
                TripSummary(title: "Weekend Getaway", destination: "Paris", packedCount: 3, totalCount: 12, progress: 0.25, daysUntilDeparture: 5),
                TripSummary(title: "Business Trip", destination: "London", packedCount: 8, totalCount: 10, progress: 0.8, daysUntilDeparture: 2)
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ProgressEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProgressEntry>) -> Void) {
        Task { @MainActor in
            let entry = await fetchProgress()
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
            completion(timeline)
        }
    }

    @MainActor
    private func fetchProgress() async -> ProgressEntry {
        let schema = Schema([Trip.self, PackingItem.self])
        let groupConfig = ModelConfiguration(groupContainer: .identifier("group.com.packwise"))
        guard let container = try? ModelContainer(for: schema, configurations: [groupConfig]) else {
            return ProgressEntry(date: Date(), trips: [])
        }
        let context = container.mainContext
        var descriptor = FetchDescriptor<Trip>(
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        descriptor.fetchLimit = 20

        guard let trips = try? context.fetch(descriptor) else {
            return ProgressEntry(date: Date(), trips: [])
        }

        let summaries: [TripSummary] = trips
            .filter { !$0.isPast && $0.items.count > 0 }
            .prefix(5)
            .map { trip in
                TripSummary(
                    title: trip.title,
                    destination: trip.destination,
                    packedCount: trip.items.filter(\.packed).count,
                    totalCount: trip.items.count,
                    progress: trip.progress,
                    daysUntilDeparture: trip.daysUntilDeparture
                )
            }

        return ProgressEntry(date: Date(), trips: summaries)
    }
}

// MARK: - Widget View

struct PackingProgressWidgetView: View {
    let entry: ProgressEntry

    var body: some View {
        if entry.trips.isEmpty {
            emptyView
        } else {
            tripsList
        }
    }

    private var tripsList: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "checklist")
                    .font(.caption.bold())
                    .foregroundStyle(.green)
                Text("Packing Progress")
                    .font(.caption.bold())
                Spacer()
            }
            Divider()
            ForEach(entry.trips.indices, id: \.self) { idx in
                let trip = entry.trips[idx]
                tripRow(trip)
                if idx < entry.trips.count - 1 {
                    Divider().opacity(0.3)
                }
            }
        }
        .padding(10)
    }

    private func tripRow(_ trip: TripSummary) -> some View {
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 1) {
                Text(trip.title)
                    .font(.caption.bold())
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text(trip.destination)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    if let days = trip.daysUntilDeparture {
                        Text("·")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(days <= 0 ? "Today" : "\(days)d")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                }
            }
            Spacer(minLength: 4)
            VStack(alignment: .trailing, spacing: 2) {
                ProgressView(value: trip.progress)
                    .tint(trip.progress >= 1 ? .green : .blue)
                    .frame(width: 48)
                Text("\(trip.packedCount)/\(trip.totalCount)")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 4) {
            Image(systemName: "suitcase")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No Active Trips")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text("Add packing items to see progress here")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .multilineTextAlignment(.center)
        .padding(8)
    }
}

#if DEBUG
#Preview("Packing Progress", as: .systemMedium) {
    PackingProgressWidget()
} timeline: {
    ProgressEntry(date: Date(), trips: [
        TripSummary(title: "Weekend Getaway", destination: "Paris", packedCount: 3, totalCount: 12, progress: 0.25, daysUntilDeparture: 5),
        TripSummary(title: "Business Trip", destination: "London", packedCount: 8, totalCount: 10, progress: 0.8, daysUntilDeparture: 2)
    ])
}
#endif
