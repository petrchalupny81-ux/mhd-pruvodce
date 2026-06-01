import Foundation

@MainActor
final class ConnectionDetailViewModel: ObservableObject {
    @Published var connection: Connection
    @Published var selectedStop: StopTime?
    @Published var selectedTimings: Set<AlertTiming> = [.fiveMinutes]
    @Published var isLoadingRealtime = false

    let networkService: NetworkService
    private var realtimeTask: Task<Void, Never>?

    init(connection: Connection, networkService: NetworkService) {
        self.connection = connection
        self.networkService = networkService
    }

    var allStops: [StopTime] {
        connection.segments.flatMap { $0.allStops }
    }

    var canActivate: Bool {
        selectedStop != nil && !selectedTimings.isEmpty
    }

    func select(stopTime: StopTime) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedStop = selectedStop?.id == stopTime.id ? nil : stopTime
        }
    }

    func toggle(timing: AlertTiming) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedTimings.contains(timing) {
                selectedTimings.remove(timing)
            } else {
                selectedTimings.insert(timing)
            }
        }
    }

    func refreshRealtime() {
        realtimeTask?.cancel()
        realtimeTask = Task {
            isLoadingRealtime = true
            do {
                let updated = try await networkService.fetchRealtimeConnection(id: connection.id)
                guard !Task.isCancelled else { return }
                connection = updated
            } catch {}
            isLoadingRealtime = false
        }
    }

    deinit {
        realtimeTask?.cancel()
    }
}
