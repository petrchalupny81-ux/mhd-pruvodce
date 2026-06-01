import Foundation

struct Connection: Codable, Identifiable, Equatable {
    static func == (lhs: Connection, rhs: Connection) -> Bool { lhs.id == rhs.id }
    let id: String
    let departureTime: Date
    let arrivalTime: Date
    let duration: Int
    let transfers: Int
    let segments: [Segment]
    let isRealtime: Bool
    let delay: Int?

    var isDelayed: Bool { (delay ?? 0) > 0 }

    var primaryLineNumber: String { segments.first?.lineNumber ?? "" }
    var primaryLineType: LineType { segments.first?.lineType ?? .bus }

    var formattedDuration: String {
        if duration >= 60 {
            let h = duration / 60
            let m = duration % 60
            return m > 0 ? "\(h) h \(m) min" : "\(h) h"
        }
        return "\(duration) min"
    }
}

struct ConnectionSearchRequest {
    let from: String
    let to: String
    let date: Date
    let time: Date
    let limit: Int

    var dateString: String {
        DateFormatter.apiDate.string(from: date)
    }

    var timeString: String {
        DateFormatter.apiTime.string(from: time)
    }
}
