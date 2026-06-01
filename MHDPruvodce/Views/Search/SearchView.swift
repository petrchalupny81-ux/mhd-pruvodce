import SwiftUI
import UIKit
import SwiftData

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \SavedSearch.timestamp, order: .reverse) private var recentSearches: [SavedSearch]

    @State private var showFromSheet = false
    @State private var showToSheet = false
    @State private var showLocationPermission = false
    @State private var navigateToResults = false

    private let networkService: NetworkService
    let locationManager: LocationManager

    init(networkService: NetworkService = CHAPSNetworkService(), locationManager: LocationManager) {
        self.networkService = networkService
        self.locationManager = locationManager
        _viewModel = StateObject(wrappedValue: SearchViewModel(networkService: networkService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    stopFields
                    dateTimeSection
                    searchButton
                    recentSearchesSection
                }
                .padding()
            }
            .navigationTitle(String(localized: "Kde jedete?"))
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $navigateToResults) {
                ConnectionListView(
                    viewModel: ConnectionListViewModel(
                        connections: viewModel.connections,
                        from: viewModel.fromStop,
                        to: viewModel.toStop,
                        networkService: networkService
                    ),
                    travelDate: viewModel.travelDate,
                    travelTime: viewModel.travelTime,
                    locationManager: locationManager
                )
            }
            .sheet(isPresented: $showFromSheet) {
                StopSearchSheet(
                    selectedStop: $viewModel.fromStop,
                    title: String(localized: "Odkud"),
                    networkService: networkService
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showToSheet) {
                StopSearchSheet(
                    selectedStop: $viewModel.toStop,
                    title: String(localized: "Kam"),
                    networkService: networkService
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showLocationPermission) {
                LocationPermissionSheet(locationManager: locationManager)
                    .presentationDetents([.medium])
            }
            .onChange(of: viewModel.connections) { _, connections in
                if !connections.isEmpty {
                    viewModel.saveSearch(context: modelContext)
                    navigateToResults = true
                }
            }
        }
    }

    private var stopFields: some View {
        VStack(spacing: 0) {
            stopField(
                placeholder: String(localized: "Odkud"),
                icon: "magnifyingglass",
                text: $viewModel.fromStop,
                action: { showFromSheet = true }
            )
            Divider().padding(.leading, 48)
            stopField(
                placeholder: String(localized: "Kam"),
                icon: "location.fill",
                text: $viewModel.toStop,
                action: { showToSheet = true }
            )
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .trailing) {
            Button {
                viewModel.swap()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundStyle(Color.appPrimary)
                    .padding()
            }
        }
    }

    private func stopField(
        placeholder: String,
        icon: String,
        text: Binding<String>,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 24)
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.tertiary)
                } else {
                    Text(text.wrappedValue)
                        .foregroundStyle(.primary)
                }
                Spacer()
            }
            .padding()
        }
        .hapticTap(style: .light)
    }

    private var dateTimeSection: some View {
        HStack(spacing: 12) {
            Label {
                DatePicker(
                    "",
                    selection: $viewModel.travelDate,
                    displayedComponents: .date
                )
                .labelsHidden()
            } icon: {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.appPrimary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Label {
                DatePicker(
                    "",
                    selection: $viewModel.travelTime,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
            } icon: {
                Image(systemName: "clock")
                    .foregroundStyle(Color.appPrimary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var searchButton: some View {
        Button {
            checkLocationAndSearch()
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(String(localized: "Hledat spoj"))
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                viewModel.canSearch
                ? LinearGradient(colors: [Color.appPrimary, Color.appPrimary.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                : LinearGradient(colors: [Color.secondary.opacity(0.3), Color.secondary.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .disabled(!viewModel.canSearch || viewModel.isLoading)
        .hapticTap(style: .medium)
    }

    @ViewBuilder
    private var recentSearchesSection: some View {
        let favorites = recentSearches.filter(\.isFavorite)
        let recent = recentSearches.filter { !$0.isFavorite }.prefix(5)

        VStack(alignment: .leading, spacing: 16) {
            if !favorites.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label(String(localized: "Oblíbené trasy"), systemImage: "star.fill")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(favorites) { search in
                                RecentSearchRow(
                                    savedSearch: search,
                                    onTap: { viewModel.apply(savedSearch: search) },
                                    onToggleFavorite: { search.isFavorite.toggle() }
                                )
                            }
                        }
                    }
                }
            }

            if !recent.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label(String(localized: "Poslední hledání"), systemImage: "clock")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(recent)) { search in
                                RecentSearchRow(
                                    savedSearch: search,
                                    onTap: { viewModel.apply(savedSearch: search) },
                                    onToggleFavorite: { search.isFavorite.toggle() }
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    private func checkLocationAndSearch() {
        if locationManager.authStatus == .notDetermined {
            showLocationPermission = true
        }
        viewModel.search()
    }
}

#Preview {
    SearchView(
        networkService: MockNetworkService(),
        locationManager: LocationManager()
    )
    .modelContainer(for: SavedSearch.self, inMemory: true)
}
