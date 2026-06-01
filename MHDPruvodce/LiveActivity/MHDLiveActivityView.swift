import SwiftUI
import ActivityKit
import WidgetKit

struct MHDLiveActivityView: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MHDJourneyAttributes.self) { context in
            // Lock Screen / Notification Center
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("→ \(context.attributes.destinationStop)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Další: \(context.state.nextStopName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("~\(context.state.minutesRemaining) min")
                        .font(.title2.bold())
                        .foregroundStyle(Color(.appPrimary))
                    if context.state.isDelayed {
                        Text("+\(context.state.delayMinutes) min")
                            .font(.caption.bold())
                            .foregroundStyle(Color(.appDanger))
                    } else {
                        Text("Včas")
                            .font(.caption.bold())
                            .foregroundStyle(Color(.appSuccess))
                    }
                }
            }
            .padding()
            .activityBackgroundTint(Color(.systemBackground))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.state.currentLine, systemImage: "tram.fill")
                        .font(.headline)
                        .foregroundStyle(Color(.appPrimary))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("~\(context.state.minutesRemaining) min")
                        .font(.headline.bold())
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("→ \(context.attributes.destinationStop)")
                        .font(.subheadline)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Na zastávce: \(context.state.nextStopName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                // Line badge
                Text(context.state.currentLine)
                    .font(.caption.bold())
                    .padding(.horizontal, 6)
                    .background(Color(.appPrimary))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            } compactTrailing: {
                Text("~\(context.state.minutesRemaining) min")
                    .font(.caption.bold())
            } minimal: {
                Text("\(context.state.minutesRemaining)")
                    .font(.caption.bold())
            }
        }
    }
}
