import Foundation

protocol NetworkService: Sendable {
    func searchConnections(request: ConnectionSearchRequest) async throws -> [Connection]
    func searchStops(query: String) async throws -> [Stop]
    func fetchRealtimeConnection(id: String) async throws -> Connection
}
