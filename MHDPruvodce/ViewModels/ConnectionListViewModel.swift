import Foundation

@MainActor
final class ConnectionListViewModel: ObservableObject {
    @Published var connections: [Connection]
    @Published var isRefreshing = false
    @Published var error: NetworkError?

    let from: String
    let to: String
    let networkService: NetworkService

    private var refreshTask: Task<Void, Never>?

    init(connections: [Connection], from: String, to: String, networkService: NetworkService) {
        self.connections = connections
        self.from = from
        self.to = to
        self.networkService = networkService
    }

    func refresh(date: Date, time: Date) async {
        refreshTask?.cancel()
        refreshTask = Task {
            isRefreshing = true
            error = nil
            do {
                let request = ConnectionSearchRequest(from: from, to: to, date: date, time: time, limit: 5)
                let results = try await networkService.searchConnections(request: request)
                guard !Task.isCancelled else { return }
                connections = results
            } catch let e as NetworkError where e != .cancelled {
                error = e
            } catch {}
            isRefreshing = false
        }
        await refreshTask?.value
    }
}

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
