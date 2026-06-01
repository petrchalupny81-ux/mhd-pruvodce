import SwiftUI

struct ConnectionListView: View {
    @StateObject private var viewModel: ConnectionListViewModel
    let travelDate: Date
    let travelTime: Date
    let locationManager: LocationManager

    init(
        viewModel: ConnectionListViewModel,
        travelDate: Date,
        travelTime: Date,
        locationManager: LocationManager
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.travelDate = travelDate
        self.travelTime = travelTime
        self.locationManager = locationManager
    }

    var body: some View {
        Group {
            if let error = viewModel.error, viewModel.connections.isEmpty {
                ScrollView {
                    ErrorBannerView(error: error) {
                        Task { await viewModel.refresh(date: travelDate, time: travelTime) }
                    }
                    .padding(.top)
                }
            } else if !viewModel.isRefreshing && viewModel.connections.isEmpty {
                EmptyStateView(
                    systemImage: "tram.fill",
                    title: String(localized: "Žádné spoje nenalezeny"),
                    subtitle: String(localized: "Žádné přímé spoje. Zkuste jiný čas."),
                    actionTitle: String(localized: "Zkusit znovu"),
                    action: { Task { await viewModel.refresh(date: travelDate, time: travelTime) } }
                )
            } else {
                List {
                    if let error = viewModel.error {
                        ErrorBannerView(error: error) {
                            Task { await viewModel.refresh(date: travelDate, time: travelTime) }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }

                    ForEach(viewModel.connections) { connection in
                        NavigationLink {
                            ConnectionDetailView(
                                viewModel: ConnectionDetailViewModel(
                                    connection: connection,
                                    networkService: viewModel.networkService
                                ),
                                locationManager: locationManager
                            )
                        } label: {
                            ConnectionRowView(connection: connection)
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refresh(date: travelDate, time: travelTime)
                }
            }
        }
        .navigationTitle("\(viewModel.from) → \(viewModel.to)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ConnectionListView(
            viewModel: ConnectionListViewModel(
                connections: PreviewData.connections,
                from: "Náměstí Míru",
                to: "Hlavní nádraží",
                networkService: MockNetworkService()
            ),
            travelDate: .now,
            travelTime: .now,
            locationManager: LocationManager()
        )
    }
}
