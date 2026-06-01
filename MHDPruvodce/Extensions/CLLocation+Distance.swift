import CoreLocation

extension CLLocation {
    var isValid: Bool {
        coordinate.latitude != 0 || coordinate.longitude != 0
    }

    func distanceInMeters(to other: CLLocation) -> Double? {
        guard isValid && other.isValid else { return nil }
        return distance(from: other)
    }
}
