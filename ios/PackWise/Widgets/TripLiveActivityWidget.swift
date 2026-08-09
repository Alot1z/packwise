import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Lock Screen / StandBy presentation

/// Lock-screen card for the departure Live Activity.
/// Colors mirror `PackWiseDesign.Color` (terracotta/amber) — the widget target
/// does not compile `DesignSystem/`, so the tokens are inlined here.
struct TripLiveActivityView: View {
    let context: ActivityViewContext<TripActivityAttributes>

    private var progress: Double {
        TripActivitySupport.progress(packed: context.state.packedCount, total: context.state.totalCount)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "airplane.departure")
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Color(red: 0.75, green: 0.32, blue: 0.20)))
            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.tripName)
                    .font(.headline)
                    .lineLimit(1)
                Text(context.attributes.destination)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                ProgressView(value: progress)
                    .tint(Color(red: 0.90, green: 0.65, blue: 0.20))
                Text("\(context.state.packedCount)/\(context.state.totalCount) packed · \(TripActivitySupport.countdownLabel(departure: context.attributes.departureDate, now: .now))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .activityBackgroundTint(Color(red: 0.97, green: 0.96, blue: 0.94))
        .activitySystemActionForegroundColor(Color(red: 0.15, green: 0.13, blue: 0.12))
    }
}

// MARK: - Widget definition

/// The departure countdown Live Activity: lock screen, StandBy, Dynamic Island.
struct TripLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TripActivityAttributes.self) { context in
            TripLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.tripName, systemImage: "airplane.departure")
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.packedCount)/\(context.state.totalCount)")
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.destination)
                            .font(.caption)
                            .lineLimit(1)
                        ProgressView(value: TripActivitySupport.progress(packed: context.state.packedCount, total: context.state.totalCount))
                            .tint(Color(red: 0.90, green: 0.65, blue: 0.20))
                    }
                }
            } compactLeading: {
                Image(systemName: "airplane.departure")
            } compactTrailing: {
                Text("\(Int(TripActivitySupport.progress(packed: context.state.packedCount, total: context.state.totalCount) * 100))%")
            } minimal: {
                Image(systemName: "airplane.departure")
            }
        }
    }
}
