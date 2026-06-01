import Foundation
import ActivityKit

@MainActor
final class LiveActivityManager: ObservableObject {
    @Published var isActivityActive = false

    private var activity: Activity<MHDJourneyAttributes>?

    var areActivitiesAvailable: Bool {
        guard #available(iOS 16.1, *) else { return false }
        return ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func startActivity(
        destinationStop: String,
        journeyID: String,
        nextStopName: String,
        minutesRemaining: Int,
        currentLine: String,
        isDelayed: Bool,
        delayMinutes: Int
    ) {
        guard areActivitiesAvailable else { return }
        guard #available(iOS 16.1, *) else { return }

        let attributes = MHDJourneyAttributes(
            destinationStop: destinationStop,
            journeyId: journeyID
        )
        let state = MHDJourneyAttributes.ContentState(
            nextStopName: nextStopName,
            minutesRemaining: minutesRemaining,
            currentLine: currentLine,
            isDelayed: isDelayed,
            delayMinutes: delayMinutes
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                contentState: state,
                pushType: nil
            )
            isActivityActive = true
        } catch {
            // LiveActivity unavailable — continue without it
        }
    }

    func updateActivity(
        nextStopName: String,
        minutesRemaining: Int,
        currentLine: String,
        isDelayed: Bool,
        delayMinutes: Int
    ) {
        guard #available(iOS 16.1, *) else { return }
        guard let activity else { return }

        let newState = MHDJourneyAttributes.ContentState(
            nextStopName: nextStopName,
            minutesRemaining: minutesRemaining,
            currentLine: currentLine,
            isDelayed: isDelayed,
            delayMinutes: delayMinutes
        )
        Task {
            await activity.update(using: newState)
        }
    }

    func endActivity() {
        guard #available(iOS 16.1, *) else { return }
        guard let activity else { return }
        Task {
            await activity.end(dismissalPolicy: .immediate)
            self.activity = nil
            self.isActivityActive = false
        }
    }
}
