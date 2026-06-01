import Foundation
import CoreLocation

struct Stop: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let city: String?
    let latitude: Double?
    let longitude: Double?
    let lines: [String]?

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude,
              lat != 0 || lon != 0 else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var clLocation: CLLocation? {
        guard let coord = coordinate else { return nil }
        return CLLocation(latitude: coord.latitude, longitude: coord.longitude)
    }

    var displayName: String {
        if let city, !city.isEmpty {
            return "\(name), \(city)"
        }
        return name
    }

    static func == (lhs: Stop, rhs: Stop) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
