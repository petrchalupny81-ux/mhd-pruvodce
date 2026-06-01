import Testing
import Foundation
@testable import MHDPruvodce

@Suite("NetworkService")
struct NetworkServiceTests {

    @Test("Mock vrací vzorové zastávky")
    func mockReturnsStops() async throws {
        let service = MockNetworkService()
        service.simulateDelay = 0
        let stops = try await service.searchStops(query: "Náměstí")
        #expect(!stops.isEmpty)
        #expect(stops.allSatisfy { !$0.id.isEmpty })
    }

    @Test("Mock vrací spoje pro hledání")
    func mockReturnsConnections() async throws {
        let service = MockNetworkService()
        service.simulateDelay = 0
        let request = ConnectionSearchRequest(
            from: "Náměstí Míru",
            to: "Hlavní nádraží",
            date: .now,
            time: .now,
            limit: 5
        )
        let connections = try await service.searchConnections(request: request)
        #expect(!connections.isEmpty)
        #expect(connections.allSatisfy { $0.duration > 0 })
    }

    @Test("Chybující mock hodí NetworkError")
    func failingMockThrows() async throws {
        let service = MockNetworkService()
        service.simulateDelay = 0
        service.shouldFail = true
        await #expect(throws: NetworkError.self) {
            _ = try await service.searchStops(query: "Praha")
        }
    }

    @Test("ConnectionSearchRequest formátuje datum správně")
    func requestDateFormat() {
        let calendar = Calendar.current
        var comps = DateComponents()
        comps.year = 2024; comps.month = 6; comps.day = 15
        comps.hour = 9; comps.minute = 30
        let date = calendar.date(from: comps)!
        let request = ConnectionSearchRequest(from: "A", to: "B", date: date, time: date, limit: 5)
        #expect(request.dateString == "2024-06-15")
        #expect(request.timeString == "9:30")
    }
}
