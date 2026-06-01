import Foundation

struct Segment: Codable, Identifiable {
    let id: String
    let lineNumber: String
    let lineType: LineType
    let departureStop: Stop
    let arrivalStop: Stop
    let departureTime: Date
    let arrivalTime: Date
    let intermediateStops: [StopTime]
    let platform: String?
    let headsign: String?

    var durationMinutes: Int {
        Int(arrivalTime.timeIntervalSince(departureTime) / 60)
    }

    var allStops: [StopTime] {
        let departure = StopTime(
            id: "dep-\(id)",
            stop: departureStop,
            scheduledTime: departureTime,
            actualTime: nil,
            platform: platform
        )
        let arrival = StopTime(
            id: "arr-\(id)",
            stop: arrivalStop,
            scheduledTime: arrivalTime,
            actualTime: nil,
            platform: nil
        )
        return [departure] + intermediateStops + [arrival]
    }
}
