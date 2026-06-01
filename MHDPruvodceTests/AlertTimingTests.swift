import Testing
import CoreLocation
@testable import MHDPruvodce

@Suite("AlertTiming")
struct AlertTimingTests {

    @Test("Vzdálenostní prahy jsou správné")
    func radiiAreCorrect() {
        #expect(AlertTiming.tenMinutes.radiusMeters   == 800)
        #expect(AlertTiming.fiveMinutes.radiusMeters  == 400)
        #expect(AlertTiming.threeMinutes.radiusMeters == 250)
        #expect(AlertTiming.twoMinutes.radiusMeters   == 150)
        #expect(AlertTiming.atStop.radiusMeters       == 80)
    }

    @Test("Časové minuty jsou správné")
    func minutesBeforeAreCorrect() {
        #expect(AlertTiming.tenMinutes.minutesBefore   == 10)
        #expect(AlertTiming.fiveMinutes.minutesBefore  == 5)
        #expect(AlertTiming.threeMinutes.minutesBefore == 3)
        #expect(AlertTiming.twoMinutes.minutesBefore   == 2)
        #expect(AlertTiming.atStop.minutesBefore       == 0)
    }

    @Test("Vzdálenost k zastávce bez souřadnic vrátí nil")
    func distanceToStopWithoutCoordinates() {
        let locationManager = LocationManager()
        let stopNoCoord = Stop(id: "1", name: "Test", city: nil, latitude: nil, longitude: nil, lines: nil)
        let dist = locationManager.distance(to: stopNoCoord)
        #expect(dist == nil)
    }

    @Test("Zastávka s nulovou polohou (0,0) vrátí nil koordinát")
    func zeroCoordinateReturnsNil() {
        let stop = Stop(id: "1", name: "Test", city: nil, latitude: 0, longitude: 0, lines: nil)
        #expect(stop.coordinate == nil)
    }

    @Test("Zastávka s platnou polohou vrátí koordinát")
    func validCoordinateReturned() {
        let stop = Stop(id: "1", name: "Test", city: nil, latitude: 50.07, longitude: 14.43, lines: nil)
        #expect(stop.coordinate != nil)
        #expect(abs((stop.coordinate?.latitude ?? 0) - 50.07) < 0.0001)
    }
}
