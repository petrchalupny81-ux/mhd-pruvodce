import Foundation
import CoreLocation
import Combine

enum LocationAuthStatus {
    case notDetermined, denied, restricted, whenInUse, always
}

enum AlertTiming: String, CaseIterable, Identifiable {
    case tenMinutes = "10 min"
    case fiveMinutes = "5 min"
    case threeMinutes = "3 min"
    case twoMinutes = "2 min"
    case atStop = "Na zastávce"

    var id: String { rawValue }

    var radiusMeters: Double {
        switch self {
        case .tenMinutes:   return 800
        case .fiveMinutes:  return 400
        case .threeMinutes: return 250
        case .twoMinutes:   return 150
        case .atStop:       return 80
        }
    }

    var minutesBefore: Int {
        switch self {
        case .tenMinutes:   return 10
        case .fiveMinutes:  return 5
        case .threeMinutes: return 3
        case .twoMinutes:   return 2
        case .atStop:       return 0
        }
    }
}

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published var authStatus: LocationAuthStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var isTracking = false
    @Published var isLowPowerMode = false

    private let manager = CLLocationManager()
    private var locationSubject = PassthroughSubject<CLLocation, Never>()
    var locationPublisher: AnyPublisher<CLLocation, Never> { locationSubject.eraseToAnyPublisher() }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 50
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.showsBackgroundLocationIndicator = true
        updateAuthStatus()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(powerStateChanged),
            name: .NSProcessInfoPowerStateDidChange,
            object: nil
        )
        isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        guard authStatus == .always || authStatus == .whenInUse else { return }
        isTracking = true
        if isLowPowerMode {
            manager.startMonitoringSignificantLocationChanges()
        } else {
            manager.startUpdatingLocation()
        }
    }

    func stopTracking() {
        isTracking = false
        manager.stopUpdatingLocation()
        manager.stopMonitoringSignificantLocationChanges()
    }

    func distance(to stop: Stop) -> Double? {
        guard let current = currentLocation,
              let stopLocation = stop.clLocation else { return nil }
        let dist = current.distance(from: stopLocation)
        guard dist > 0 else { return nil }
        return dist
    }

    private func updateAuthStatus() {
        switch manager.authorizationStatus {
        case .notDetermined:         authStatus = .notDetermined
        case .denied:                authStatus = .denied
        case .restricted:            authStatus = .restricted
        case .authorizedWhenInUse:   authStatus = .whenInUse
        case .authorizedAlways:      authStatus = .always
        @unknown default:            authStatus = .notDetermined
        }
    }

    @objc private func powerStateChanged() {
        isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        if isTracking {
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
            if isLowPowerMode {
                manager.startMonitoringSignificantLocationChanges()
            } else {
                manager.startUpdatingLocation()
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in updateAuthStatus() }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = location
            self.locationSubject.send(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location errors are expected (e.g. in simulator) — silently continue
    }
}
