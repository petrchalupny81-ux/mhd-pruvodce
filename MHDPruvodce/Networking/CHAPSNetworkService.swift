import Foundation

final class CHAPSNetworkService: NetworkService {
    private let session: URLSession
    private let apiKey: String
    private let maxRetries = 3

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        session = URLSession(configuration: config)
        apiKey = ConfigManager.shared.chapsAPIKey
    }

    func searchConnections(request: ConnectionSearchRequest) async throws -> [Connection] {
        let endpoint = APIEndpoint.searchConnections(
            from: request.from,
            to: request.to,
            date: request.dateString,
            time: request.timeString,
            limit: request.limit
        )
        let response: ConnectionsResponse = try await fetch(endpoint: endpoint)
        return response.connections
    }

    func searchStops(query: String) async throws -> [Stop] {
        let endpoint = APIEndpoint.searchStops(query: query, limit: 10)
        let response: StopsResponse = try await fetch(endpoint: endpoint)
        return response.stops
    }

    func fetchRealtimeConnection(id: String) async throws -> Connection {
        let endpoint = APIEndpoint.connectionRealtime(id: id)
        let response: RealtimeResponse = try await fetch(endpoint: endpoint)
        return response.connection
    }

    // MARK: - Private

    private func fetch<T: Decodable>(endpoint: APIEndpoint, attempt: Int = 0) async throws -> T {
        guard let url = endpoint.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse else { throw NetworkError.noData }

            switch http.statusCode {
            case 200...299:
                break
            case 401, 403:
                throw NetworkError.serverError(http.statusCode)
            default:
                if attempt < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
                    return try await fetch(endpoint: endpoint, attempt: attempt + 1)
                }
                throw NetworkError.serverError(http.statusCode)
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternet
            case .timedOut:
                if attempt < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
                    return try await fetch(endpoint: endpoint, attempt: attempt + 1)
                }
                throw NetworkError.timeout
            case .cancelled:
                throw NetworkError.cancelled
            default:
                if attempt < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
                    return try await fetch(endpoint: endpoint, attempt: attempt + 1)
                }
                throw NetworkError.serverError(-1)
            }
        }
    }
}

// MARK: - Response wrappers

private struct ConnectionsResponse: Decodable {
    let connections: [Connection]
}

private struct StopsResponse: Decodable {
    let stops: [Stop]
}

private struct RealtimeResponse: Decodable {
    let connection: Connection
}
