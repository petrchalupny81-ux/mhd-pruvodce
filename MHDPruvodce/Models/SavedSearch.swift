import Foundation
import SwiftData

@Model
final class SavedSearch {
    var fromStop: String
    var toStop: String
    var timestamp: Date
    var isFavorite: Bool

    init(fromStop: String, toStop: String, timestamp: Date = .now, isFavorite: Bool = false) {
        self.fromStop = fromStop
        self.toStop = toStop
        self.timestamp = timestamp
        self.isFavorite = isFavorite
    }

    var displayTitle: String { "\(fromStop) → \(toStop)" }
}
