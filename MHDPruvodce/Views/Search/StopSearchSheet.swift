import SwiftUI
import UIKit
import Combine

struct StopSearchSheet: View {
    @Binding var selectedStop: String
    let title: String
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var results: [Stop] = []
    @State private var isLoading = false
    @State private var error: NetworkError?

    private let networkService: NetworkService
    @State private var searchTask: Task<Void, Never>?
    @State private var debounceTask: Task<Void, Never>?

    init(selectedStop: Binding<String>, title: String, networkService: NetworkService = CHAPSNetworkService()) {
        self._selectedStop = selectedStop
        self.title = title
        self.networkService = networkService
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField
                Divider()
                resultsList
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Zrušit")) { dismiss() }
                }
            }
        }
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(String(localized: "Název zastávky…"), text: $query)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .onAppear {
                    // Auto-focus
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {}
                }
                .onChange(of: query) { _, newValue in
                    scheduleSearch(query: newValue)
                }
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else if !query.isEmpty {
                Button {
                    query = ""
                    results = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private var resultsList: some View {
        if query.isEmpty {
            EmptyStateView(
                systemImage: "magnifyingglass",
                title: String(localized: "Hledejte zastávku"),
                subtitle: String(localized: "Začněte psát název zastávky nebo města.")
            )
            .frame(maxHeight: .infinity)
        } else if let error {
            EmptyStateView(
                systemImage: "wifi.slash",
                title: String(localized: "Chyba připojení"),
                subtitle: error.errorDescription ?? "",
                actionTitle: String(localized: "Zkusit znovu"),
                action: { scheduleSearch(query: query) }
            )
            .frame(maxHeight: .infinity)
        } else if !isLoading && results.isEmpty {
            EmptyStateView(
                systemImage: "mappin.slash",
                title: String(localized: "Zastávka nenalezena"),
                subtitle: String(localized: "Zkuste jiný název nebo město.")
            )
            .frame(maxHeight: .infinity)
        } else {
            List(results) { stop in
                Button {
                    selectedStop = stop.name
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stop.name)
                            .font(.body)
                            .foregroundStyle(.primary)
                        if let city = stop.city {
                            Text(city)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .accessibilityLabel("\(stop.name)\(stop.city.map { ", \($0)" } ?? "")")
            }
            .listStyle(.plain)
        }
    }

    private func scheduleSearch(query: String) {
        debounceTask?.cancel()
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            error = nil
            return
        }
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await performSearch(query: query)
        }
    }

    @MainActor
    private func performSearch(query: String) async {
        searchTask?.cancel()
        searchTask = Task {
            isLoading = true
            error = nil
            do {
                let found = try await networkService.searchStops(query: query)
                guard !Task.isCancelled else { return }
                results = found
            } catch let e as NetworkError where e != .cancelled {
                guard !Task.isCancelled else { return }
                self.error = e
            } catch {}
            isLoading = false
        }
    }
}

#Preview {
    StopSearchSheet(
        selectedStop: .constant(""),
        title: "Odkud",
        networkService: MockNetworkService()
    )
}
