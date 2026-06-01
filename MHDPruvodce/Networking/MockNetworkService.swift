import Foundation

final class MockNetworkService: NetworkService {
    var simulateDelay: TimeInterval = 0.6
    var shouldFail = false

    func searchConnections(request: ConnectionSearchRequest) async throws -> [Connection] {
        try await simulateNetwork()
        if shouldFail { throw NetworkError.noInternet }
        return PreviewData.connections
    }

    func searchStops(query: String) async throws -> [Stop] {
        try await simulateNetwork(delay: 0.3)
        if shouldFail { throw NetworkError.noInternet }
        return PreviewData.stops.filter {
            query.isEmpty || $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    func fetchRealtimeConnection(id: String) async throws -> Connection {
        try await simulateNetwork()
        guard let conn = PreviewData.connections.first(where: { $0.id == id }) else {
            throw NetworkError.serverError(404)
        }
        return conn
    }

    private func simulateNetwork(delay: TimeInterval? = nil) async throws {
        let d = delay ?? simulateDelay
        try await Task.sleep(nanoseconds: UInt64(d * 1_000_000_000))
    }
}
