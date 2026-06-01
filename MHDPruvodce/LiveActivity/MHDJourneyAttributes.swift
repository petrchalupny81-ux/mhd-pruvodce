import Foundation
import ActivityKit

struct MHDJourneyAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var nextStopName: String
        var minutesRemaining: Int
        var currentLine: String
        var isDelayed: Bool
        var delayMinutes: Int
    }

    let destinationStop: String
    let journeyId: String
}
