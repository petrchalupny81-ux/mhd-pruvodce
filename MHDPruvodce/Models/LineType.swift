import SwiftUI

enum LineType: String, Codable, CaseIterable {
    case bus
    case tram
    case metro
    case train
    case trolleybus
    case ferry

    var color: Color {
        switch self {
        case .bus:        return Color(.busBadge)
        case .tram:       return Color(.tramBadge)
        case .metro:      return Color(.metroBadge)
        case .train:      return Color(.trainBadge)
        case .trolleybus: return Color(.trolleybusBadge)
        case .ferry:      return Color(.primary)
        }
    }

    var icon: String {
        switch self {
        case .bus:        return "bus.fill"
        case .tram:       return "tram.fill"
        case .metro:      return "tram.circle.fill"
        case .train:      return "train.side.front.car"
        case .trolleybus: return "bolt.car.fill"
        case .ferry:      return "ferry.fill"
        }
    }

    var localizedName: String {
        switch self {
        case .bus:        return "Autobus"
        case .tram:       return "Tramvaj"
        case .metro:      return "Metro"
        case .train:      return "Vlak"
        case .trolleybus: return "Trolejbus"
        case .ferry:      return "Přívoz"
        }
    }
}
