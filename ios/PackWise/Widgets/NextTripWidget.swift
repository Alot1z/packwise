import SwiftUI
import WidgetKit
import SwiftData

// MARK: - Next Trip Widget

/// Shows the next upcoming trip (not past, sorted by start date).
/// Tap opens the app.

struct NextTripWidget: Widget {
    let kind: String = "com.packwise.widget.nexttrip"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextTripProvider()) { entry in
            NextTripWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next Trip")
        .description("Shows your next upcoming trip and packing progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline Entry

struct NextTripEntry: TimelineEntry {
    let date: Date
    let tripTitle: String?
    let destination: String?
    let daysUntilDeparture: Int?
    let packedCount: Int
    let totalCount: Int
    let progress: Double
}

// MARK: - Timeline Provider

struct NextTripProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextTripEntry {
        NextTripEntry(
            date: Date(),
            tripTitle: "Weekend Getaway",
            destination: "Paris",
            daysUntilDeparture: 5,
            packedCount: 3,
            totalCount: 12,
            progress: 0.25
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NextTripEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<NextTripEntry>) -> Void) {
        Task {
            let entry = await fetchNextTrip()
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
            completion(timeline)
        }
    }

    @MainActor
    private func fetchNextTrip() async -> NextTripEntry {
        let schema = Schema([Trip.self, PackingItem.self])
        let groupConfig = ModelConfiguration(groupContainer: .identifier("group.com.packwise"))
        guard let container = try? ModelContainer(for: schema, configurations: [groupConfig]) else {
            return NextTripEntry(date: Date(), tripTitle: nil, destination: nil, daysUntilDeparture: nil, packedCount: 0, totalCount: 0, progress: 0)
        }
        let context = container.mainContext
        let now = Date()
        var descriptor = FetchDescriptor<Trip>(
            predicate: #Predicate { $0.startDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        descriptor.fetchLimit = 10

        guard let trips = try? context.fetch(descriptor) else {
            return NextTripEntry(date: now, tripTitle: nil, destination: nil, daysUntilDeparture: nil, packedCount: 0, totalCount: 0, progress: 0)
        }

        let upcoming = trips.first(where: { !$0.isPast && $0.startDate != nil })
        guard let trip = upcoming else {
            return NextTripEntry(date: now, tripTitle: nil, destination: nil, daysUntilDeparture: nil, packedCount: 0, totalCount: 0, progress: 0)
        }

        return NextTripEntry(
            date: now,
            tripTitle: trip.title,
            destination: trip.destination,
            daysUntilDeparture: trip.daysUntilDeparture,
            packedCount: trip.items.filter(\.packed).count,
            totalCount: trip.items.count,
            progress: trip.progress
        )
    }
}

// MARK: - Widget View

struct NextTripWidgetView: View {
    let entry: NextTripEntry

    var body: some View {
        if let title = entry.tripTitle {
            contentView(title: title)
        } else {
            emptyView
        }
    }

    private func contentView(title: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "airplane.departure")
                    .font(.caption)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.caption.bold())
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            if let dest = entry.destination {
                Text(dest)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            if let days = entry.daysUntilDeparture {
                Text(days <= 0 ? "Today!" : "\(days) day\(days == 1 ? "" : "s") away")
                    .font(.caption2)
                    .foregroundStyle(.blue)
            }
            Spacer(minLength: 4)
            if entry.totalCount > 0 {
                ProgressView(value: entry.progress)
                    .tint(.green)
                Text("\(entry.packedCount)/\(entry.totalCount) packed")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
    }

    private var emptyView: some View {
        VStack(spacing: 4) {
            Image(systemName: "airplane")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No Upcoming Trips")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text("Create one in PackWise")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .multilineTextAlignment(.center)
        .padding(8)
    }
}

#if DEBUG
#Preview("Next Trip", as: .systemSmall) {
    NextTripWidget()
} timeline: {
    NextTripEntry(date: Date(), tripTitle: "Weekend Getaway", destination: "Paris", daysUntilDeparture: 5, packedCount: 3, totalCount: 12, progress: 0.25)
}
#endif
