import SwiftUI
import UIKit
import CoreLocation

struct ActiveTrackingView: View {
    @StateObject private var viewModel: TrackingViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var pulseScale: CGFloat = 1.0
    @State private var showStopConfirmation = false

    init(viewModel: TrackingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                if !viewModel.headphonesConnected {
                    HeadphoneDisconnectedBannerView()
                        .padding(.top)
                }

                if viewModel.trackingManager.locationManager.isLowPowerMode {
                    HStack(spacing: 8) {
                        Image(systemName: "battery.25")
                            .foregroundStyle(Color.appWarning)
                        Text(String(localized: "Režim úspory energie – aktualizace polohy omezeny"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                ScrollView {
                    VStack(spacing: 28) {
                        pulsingIndicator
                        destinationInfo
                        upcomingStops
                        mapSection
                        locationDebug
                    }
                    .padding()
                }

                stopButton
            }
        }
        .navigationTitle(String(localized: "Sledování trasy"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "Zpět")) {
                    showStopConfirmation = true
                }
            }
        }
        .confirmationDialog(
            String(localized: "Zastavit sledování?"),
            isPresented: $showStopConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Zastavit sledování"), role: .destructive) {
                viewModel.stop()
                dismiss()
            }
            Button(String(localized: "Pokračovat"), role: .cancel) {}
        }
        .onChange(of: viewModel.state) { _, newState in
            if case .arrived = newState {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.15
            }
        }
    }

    // MARK: - Subviews

    private var pulsingIndicator: some View {
        ZStack {
            Circle()
                .fill(stateColor.opacity(0.2))
                .frame(width: 130, height: 130)
                .scaleEffect(pulseScale)

            Circle()
                .fill(stateColor.opacity(0.15))
                .frame(width: 100, height: 100)

            Circle()
                .fill(stateColor)
                .frame(width: 70, height: 70)
                .overlay {
                    Image(systemName: stateIcon)
                        .font(.title2)
                        .foregroundStyle(.white)
                }
        }
    }

    private var destinationInfo: some View {
        VStack(spacing: 8) {
            if case .arrived = viewModel.state {
                Text(String(localized: "Nastupujte!"))
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.appSuccess)
            } else {
                Text(String(localized: "Jedete na:"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(viewModel.targetStop?.name ?? "")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                Text(String(localized: "Příjezd za ~\(viewModel.minutesRemaining) min"))
                    .font(.headline)
                    .foregroundStyle(Color.appPrimary)
            }
        }
    }

    private var upcomingStops: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(String(localized: "Nadcházející zastávky"))
                .font(.headline)
                .padding(.bottom, 8)

            let upcoming = nextFewStops()
            if upcoming.isEmpty {
                Text(String(localized: "Žádné další zastávky"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(upcoming) { stopTime in
                    HStack {
                        Text(stopTime.stop.name)
                            .font(.subheadline)
                        Spacer()
                        Text(stopTime.displayTime.mhdTimeString)
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var mapSection: some View {
        let userCoord = viewModel.trackingManager.locationManager.currentLocation?.coordinate
        TrackingMapView(
            userLocation: userCoord,
            targetStop: viewModel.targetStop
        )
        .frame(height: 180)
    }

    @ViewBuilder
    private var locationDebug: some View {
        if let locStr = viewModel.currentLocation {
            Text(locStr)
                .font(.caption2.monospacedDigit())
                .foregroundStyle(Color(.tertiaryLabel))
        }
    }

    private var stopButton: some View {
        Button {
            showStopConfirmation = true
        } label: {
            Label(
                String(localized: "Zastavit sledování"),
                systemImage: "stop.circle.fill"
            )
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.appDanger)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding()
        .hapticTap(style: .heavy)
    }

    // MARK: - Helpers

    private var stateColor: Color {
        switch viewModel.state {
        case .arrived:  return .appSuccess
        case .stopped:  return .secondary
        default:        return .appPrimary
        }
    }

    private var stateIcon: String {
        switch viewModel.state {
        case .arrived: return "checkmark"
        case .stopped: return "stop.fill"
        default:       return "location.fill"
        }
    }

    private func nextFewStops() -> [StopTime] {
        guard let connection = viewModel.connection else { return [] }
        let now = Date()
        return connection.segments
            .flatMap { $0.allStops }
            .filter { $0.scheduledTime > now }
            .prefix(4)
            .map { $0 }
    }
}

#Preview {
    let loc = LocationManager()
    let audio = AudioManager()
    let notif = NotificationManager()
    let tracking = TrackingManager(locationManager: loc, audioManager: audio, notificationManager: notif)
    let liveActivity = LiveActivityManager()

    return NavigationStack {
        ActiveTrackingView(
            viewModel: TrackingViewModel(
                trackingManager: tracking,
                liveActivityManager: liveActivity
            )
        )
    }
}
