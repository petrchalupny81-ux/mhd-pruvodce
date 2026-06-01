import SwiftUI

struct AlertPanel: View {
    let selectedStop: StopTime
    @Binding var selectedTimings: Set<AlertTiming>
    let headphonesConnected: Bool
    let onActivate: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Divider()
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(Color.appPrimary)
                    Text(String(localized: "Připomenutí pro: \(selectedStop.stop.name)"))
                        .font(.headline)
                }

                timingButtons

                Button(action: onActivate) {
                    Label(
                        String(localized: "Aktivovat sledování"),
                        systemImage: "location.fill"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedTimings.isEmpty ? Color.secondary.opacity(0.3) : Color.appSuccess)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .disabled(selectedTimings.isEmpty)
                .hapticTap(style: .medium)

                HeadphoneStatusView(connected: headphonesConnected)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }

    private var timingButtons: some View {
        HStack(spacing: 8) {
            ForEach(AlertTiming.allCases) { timing in
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        if selectedTimings.contains(timing) {
                            selectedTimings.remove(timing)
                        } else {
                            selectedTimings.insert(timing)
                        }
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Text(timing.rawValue)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(selectedTimings.contains(timing) ? Color.appPrimary : Color(.secondarySystemBackground))
                        .foregroundStyle(selectedTimings.contains(timing) ? .white : .primary)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

#Preview {
    AlertPanel(
        selectedStop: StopTime(
            id: "1",
            stop: PreviewData.stops[0],
            scheduledTime: Date().addingTimeInterval(600),
            actualTime: nil,
            platform: nil
        ),
        selectedTimings: .constant([.fiveMinutes, .twoMinutes]),
        headphonesConnected: false,
        onActivate: {}
    )
}
