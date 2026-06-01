import Foundation
import Combine

@MainActor
final class TrackingViewModel: ObservableObject {
    @Published var minutesRemaining: Int = 0
    @Published var nextStopName: String = ""
    @Published var isTracking = false

    let trackingManager: TrackingManager
    let liveActivityManager: LiveActivityManager

    private var cancellables = Set<AnyCancellable>()

    init(trackingManager: TrackingManager, liveActivityManager: LiveActivityManager) {
        self.trackingManager = trackingManager
        self.liveActivityManager = liveActivityManager
        bind()
    }

    var connection: Connection? { trackingManager.activeConnection }
    var targetStop: Stop? { trackingManager.targetStop }
    var state: TrackingState { trackingManager.state }
    var headphonesConnected: Bool { trackingManager.audioManager.headphonesConnected }
    var currentLocation: String? {
        guard let loc = trackingManager.locationManager.currentLocation else { return nil }
        return String(format: "%.5f, %.5f", loc.coordinate.latitude, loc.coordinate.longitude)
    }

    func stop() {
        trackingManager.stopTracking()
        liveActivityManager.endActivity()
        isTracking = false
    }

    // MARK: - Private

    private func bind() {
        trackingManager.$minutesRemaining
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] mins in
                self?.minutesRemaining = mins
                self?.updateLiveActivity(minutesRemaining: mins)
            }
            .store(in: &cancellables)

        trackingManager.$nextStop
            .compactMap { $0?.stop.name }
            .receive(on: RunLoop.main)
            .assign(to: \.nextStopName, on: self)
            .store(in: &cancellables)

        trackingManager.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case .tracking: self?.isTracking = true
                case .arrived, .stopped: self?.isTracking = false
                default: break
                }
            }
            .store(in: &cancellables)
    }

    private func updateLiveActivity(minutesRemaining: Int) {
        guard let conn = connection else { return }
        liveActivityManager.updateActivity(
            nextStopName: nextStopName,
            minutesRemaining: minutesRemaining,
            currentLine: conn.primaryLineNumber,
            isDelayed: conn.isDelayed,
            delayMinutes: conn.delay ?? 0
        )
    }
}
