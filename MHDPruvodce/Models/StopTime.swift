import Foundation

struct StopTime: Codable, Identifiable {
    let id: String
    let stop: Stop
    let scheduledTime: Date
    let actualTime: Date?
    let platform: String?

    var isDelayed: Bool {
        guard let actual = actualTime else { return false }
        return actual > scheduledTime.addingTimeInterval(60)
    }

    var delayMinutes: Int {
        guard let actual = actualTime else { return 0 }
        return max(0, Int(actual.timeIntervalSince(scheduledTime) / 60))
    }

    var displayTime: Date {
        actualTime ?? scheduledTime
    }
}
