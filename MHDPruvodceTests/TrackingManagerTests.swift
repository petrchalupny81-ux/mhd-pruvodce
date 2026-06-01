import Testing
import Foundation
@testable import MHDPruvodce

@Suite("TrackingManager stavový automat")
@MainActor
struct TrackingManagerTests {

    func makeManager() -> TrackingManager {
        TrackingManager(
            locationManager: LocationManager(),
            audioManager: AudioManager(),
            notificationManager: NotificationManager()
        )
    }

    @Test("Výchozí stav je idle")
    func initialStateIsIdle() {
        let manager = makeManager()
        #expect(manager.state == .idle)
    }

    @Test("startTracking přechází do stavu tracking")
    func startTrackingChangesState() {
        let manager = makeManager()
        let conn = PreviewData.connections[0]
        let stop = PreviewData.stops[0]
        manager.startTracking(connection: conn, targetStop: stop, timings: [.fiveMinutes])
        if case .tracking(let id) = manager.state {
            #expect(id == conn.id)
        } else {
            Issue.record("Očekáván stav tracking, nalezen \(manager.state)")
        }
    }

    @Test("stopTracking přechází do stavu stopped")
    func stopTrackingChangesState() {
        let manager = makeManager()
        let conn = PreviewData.connections[0]
        manager.startTracking(connection: conn, targetStop: PreviewData.stops[0], timings: [])
        manager.stopTracking()
        #expect(manager.state == .stopped)
    }

    @Test("firedAlerts začíná prázdné")
    func firedAlertsStartEmpty() {
        let manager = makeManager()
        let conn = PreviewData.connections[0]
        manager.startTracking(connection: conn, targetStop: PreviewData.stops[0], timings: [.fiveMinutes])
        #expect(manager.firedAlerts.isEmpty)
    }

    @Test("activeConnection je nastaveno po startu")
    func activeConnectionSet() {
        let manager = makeManager()
        let conn = PreviewData.connections[0]
        manager.startTracking(connection: conn, targetStop: PreviewData.stops[0], timings: [])
        #expect(manager.activeConnection?.id == conn.id)
    }

    @Test("activeConnection je nil po zastavení")
    func activeConnectionClearedAfterStop() {
        let manager = makeManager()
        let conn = PreviewData.connections[0]
        manager.startTracking(connection: conn, targetStop: PreviewData.stops[0], timings: [])
        manager.stopTracking()
        #expect(manager.activeConnection == nil)
    }
}
