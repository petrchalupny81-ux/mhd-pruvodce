import Foundation

enum APIEndpoint {
    case searchConnections(from: String, to: String, date: String, time: String, limit: Int)
    case searchStops(query: String, limit: Int)
    case connectionRealtime(id: String)

    private var baseURL: String { ConfigManager.shared.chapsBaseURL }

    var url: URL? {
        switch self {
        case .searchConnections(let from, let to, let date, let time, let limit):
            var components = URLComponents(string: "\(baseURL)/connections")
            components?.queryItems = [
                .init(name: "from", value: from),
                .init(name: "to", value: to),
                .init(name: "date", value: date),
                .init(name: "time", value: time),
                .init(name: "limit", value: "\(limit)"),
                .init(name: "tariff", value: "PID"),
            ]
            return components?.url

        case .searchStops(let query, let limit):
            var components = URLComponents(string: "\(baseURL)/stops/search")
            components?.queryItems = [
                .init(name: "query", value: query),
                .init(name: "limit", value: "\(limit)"),
            ]
            return components?.url

        case .connectionRealtime(let id):
            return URL(string: "\(baseURL)/connection/\(id)/realtime")
        }
    }
}
