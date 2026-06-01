import Foundation
import Combine
import CoreLocation

enum TrackingState: Equatable {
    case idle
    case searching
    case tracking(journeyID: String)
    case arrived
    case stopped
}

@MainActor
final class TrackingManager: ObservableObject {
    @Published var state: TrackingState = .idle
    @Published var targetStop: Stop?
    @Published var selectedTimings: Set<AlertTiming> = []
    @Published var firedAlerts: Set<AlertTiming> = []
    @Published var activeConnection: Connection?
    @Published var minutesRemaining: Int?
    @Published var nextStop: StopTime?

    private var locationTask: Task<Void, Never>?
    private var countdownTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    let locationManager: LocationManager
    let audioManager: AudioManager
    let notificationManager: NotificationManager

    init(
        locationManager: LocationManager,
        audioManager: AudioManager,
        notificationManager: NotificationManager
    ) {
        self.locationManager = locationManager
        self.audioManager = audioManager
        self.notificationManager = notificationManager
    }

    func startTracking(
        connection: Connection,
        targetStop: Stop,
        timings: Set<AlertTiming>
    ) {
        self.activeConnection = connection
        self.targetStop = targetStop
        self.selectedTimings = timings
        self.firedAlerts = []
        state = .tracking(journeyID: connection.id)

        locationManager.startTracking()
        scheduleTimedNotifications(connection: connection, targetStop: targetStop, timings: timings)
        startCountdown(connection: connection)
        startLocationMonitoring()
    }

    func stopTracking() {
        locationTask?.cancel()
        countdownTask?.cancel()
        locationManager.stopTracking()
        notificationManager.cancelAllJourneyNotifications()
        state = .stopped
        activeConnection = nil
        targetStop = nil
        minutesRemaining = nil
        nextStop = nil
    }

    // MARK: - Private

    private func scheduleTimedNotifications(
        connection: Connection,
        targetStop: Stop,
        timings: Set<AlertTiming>
    ) {
        guard !timings.isEmpty else { return }
        let lineName = connection.segments.first?.lineNumber ?? ""
        let direction = connection.segments.last?.arrivalStop.name ?? ""

        for timing in timings {
            let triggerDate = connection.arrivalTime.addingTimeInterval(
                TimeInterval(-timing.minutesBefore * 60)
            )
            guard triggerDate > Date() else { continue }
            notificationManager.scheduleAlert(
                timing: timing,
                stopName: targetStop.name,
                lineName: lineName,
                direction: direction,
                triggerDate: triggerDate
            )
        }
    }

    private func startCountdown(connection: Connection) {
        countdownTask?.cancel()
        countdownTask = Task {
            while !Task.isCancelled {
                let remaining = Int(connection.arrivalTime.timeIntervalSinceNow / 60)
                minutesRemaining = max(0, remaining)
                nextStop = findNextStop(in: connection)

                if remaining <= 0 {
                    state = .arrived
                    audioManager.playAlert(.arrive)
                    break
                }
                try? await Task.sleep(nanoseconds: 30_000_000_000)
            }
        }
    }

    private func startLocationMonitoring() {
        locationTask?.cancel()
        locationTask = Task {
            for await location in locationManager.locationPublisher.values {
                guard let stop = targetStop else { continue }
                guard let distance = locationManager.distance(to: stop) else { continue }
                checkProximityAlerts(distance: distance, location: location)
            }
        }
    }

    private func checkProximityAlerts(distance: Double, location: CLLocation) {
        let lineName = activeConnection?.segments.first?.lineNumber ?? ""
        let direction = activeConnection?.segments.last?.arrivalStop.name ?? ""
        guard let stop = targetStop else { return }

        for timing in selectedTimings where !firedAlerts.contains(timing) {
            if distance <= timing.radiusMeters {
                firedAlerts.insert(timing)
                let sound: AlertSound = timing.radiusMeters >= 400 ? .far : (timing == .atStop ? .arrive : .near)
                audioManager.playAlert(sound)
                notificationManager.scheduleProximityAlert(
                    timing: timing,
                    stopName: stop.name,
                    lineName: lineName,
                    direction: direction
                )
            }
        }

        if distance <= AlertTiming.atStop.radiusMeters {
            state = .arrived
        }
    }

    private func findNextStop(in connection: Connection) -> StopTime? {
        let now = Date()
        for segment in connection.segments {
            for stopTime in segment.allStops where stopTime.scheduledTime > now {
                return stopTime
            }
        }
        return nil
    }
}

// MARK: - AsyncPublisher extension for Combine publisher

private extension Publisher where Failure == Never {
    var values: AsyncPublisher<Self> { AsyncPublisher(self) }
}
