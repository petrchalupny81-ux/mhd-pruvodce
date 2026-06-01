import SwiftUI
import Foundation
import SwiftData
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var fromStop: String = ""
    @Published var toStop: String = ""
    @Published var travelDate: Date = .now
    @Published var travelTime: Date = .now
    @Published var isLoading = false
    @Published var error: NetworkError?
    @Published var connections: [Connection] = []
    @Published var hasSearched = false

    let networkService: NetworkService

    private var searchTask: Task<Void, Never>?

    init(networkService: NetworkService = CHAPSNetworkService()) {
        self.networkService = networkService
    }

    var canSearch: Bool {
        !fromStop.trimmingCharacters(in: .whitespaces).isEmpty &&
        !toStop.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func search() {
        guard canSearch else { return }
        searchTask?.cancel()
        searchTask = Task {
            isLoading = true
            error = nil
            do {
                let request = ConnectionSearchRequest(
                    from: fromStop,
                    to: toStop,
                    date: travelDate,
                    time: travelTime,
                    limit: 5
                )
                let results = try await networkService.searchConnections(request: request)
                guard !Task.isCancelled else { return }
                connections = results
                hasSearched = true
            } catch let e as NetworkError {
                guard !Task.isCancelled else { return }
                error = e
            } catch {
                guard !Task.isCancelled else { return }
                self.error = .serverError(-1)
            }
            isLoading = false
        }
    }

    func swap() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            let tmp = fromStop
            fromStop = toStop
            toStop = tmp
        }
    }

    func saveSearch(context: ModelContext) {
        guard canSearch else { return }
        let existing = (try? context.fetch(
            FetchDescriptor<SavedSearch>(
                predicate: #Predicate { $0.fromStop == fromStop && $0.toStop == toStop }
            )
        )) ?? []
        if existing.isEmpty {
            let saved = SavedSearch(fromStop: fromStop, toStop: toStop)
            context.insert(saved)
        }
    }

    func apply(savedSearch: SavedSearch) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            fromStop = savedSearch.fromStop
            toStop = savedSearch.toStop
        }
    }
}
