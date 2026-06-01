import SwiftUI

struct ConnectionDetailView: View {
    @StateObject private var viewModel: ConnectionDetailViewModel
    @StateObject private var audioManager = AudioManager()

    let locationManager: LocationManager

    @EnvironmentObject private var trackingManager: TrackingManager
    @EnvironmentObject private var liveActivityManager: LiveActivityManager

    @State private var navigateToTracking = false

    init(viewModel: ConnectionDetailViewModel, locationManager: LocationManager) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.locationManager = locationManager
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            stopList

            if let selectedStop = viewModel.selectedStop {
                AlertPanel(
                    selectedStop: selectedStop,
                    selectedTimings: $viewModel.selectedTimings,
                    headphonesConnected: audioManager.headphonesConnected,
                    onActivate: activateTracking
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .navigationDestination(isPresented: $navigateToTracking) {
                    ActiveTrackingView(
                        viewModel: TrackingViewModel(
                            trackingManager: trackingManager,
                            liveActivityManager: liveActivityManager
                        )
                    )
                }
            }
        }
        .navigationTitle(String(localized: "Itinerář"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if viewModel.isLoadingRealtime {
                    ProgressView().scaleEffect(0.8)
                } else {
                    Button {
                        viewModel.refreshRealtime()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            if viewModel.connection.isRealtime {
                viewModel.refreshRealtime()
            }
        }
    }

    private var stopList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Real-time warning if no data
                if !viewModel.connection.isRealtime {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.appWarning)
                        Text(String(localized: "⚠️ Bez real-time dat — zobrazeny plánované časy"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appWarning.opacity(0.1))
                }

                ForEach(viewModel.connection.segments) { segment in
                    segmentSection(segment)
                }
            }
            .padding(.bottom, viewModel.selectedStop != nil ? 200 : 0)
        }
    }

    private func segmentSection(_ segment: Segment) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Segment header
            HStack(spacing: 12) {
                LineBadgeView(lineNumber: segment.lineNumber, lineType: segment.lineType)
                if let headsign = segment.headsign {
                    Text("→ \(headsign)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(String(localized: "\(segment.durationMinutes) min"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(.tertiarySystemBackground))

            ForEach(segment.allStops) { stopTime in
                StopRowView(
                    stopTime: stopTime,
                    isTransfer: stopTime.id == segment.allStops.first?.id || stopTime.id == segment.allStops.last?.id,
                    isSelected: viewModel.selectedStop?.id == stopTime.id,
                    onSelect: { viewModel.select(stopTime: stopTime) }
                )
                Divider().padding(.leading, 82)
            }
        }
    }

    private func activateTracking() {
        guard let selectedStop = viewModel.selectedStop else { return }
        let stop = selectedStop.stop

        trackingManager.startTracking(
            connection: viewModel.connection,
            targetStop: stop,
            timings: viewModel.selectedTimings
        )

        if liveActivityManager.areActivitiesAvailable {
            liveActivityManager.startActivity(
                destinationStop: stop.name,
                journeyID: viewModel.connection.id,
                nextStopName: stop.name,
                minutesRemaining: selectedStop.scheduledTime.minutesUntil(),
                currentLine: viewModel.connection.primaryLineNumber,
                isDelayed: viewModel.connection.isDelayed,
                delayMinutes: viewModel.connection.delay ?? 0
            )
        }

        navigateToTracking = true
    }
}

#Preview {
    NavigationStack {
        ConnectionDetailView(
            viewModel: ConnectionDetailViewModel(
                connection: PreviewData.connections[0],
                networkService: MockNetworkService()
            ),
            locationManager: LocationManager()
        )
        .environmentObject(TrackingManager(
            locationManager: LocationManager(),
            audioManager: AudioManager(),
            notificationManager: NotificationManager()
        ))
        .environmentObject(LiveActivityManager())
    }
}
