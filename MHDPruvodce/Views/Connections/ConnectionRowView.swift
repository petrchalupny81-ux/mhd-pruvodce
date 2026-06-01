import SwiftUI

struct ConnectionRowView: View {
    let connection: Connection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(connection.departureTime.mhdTimeString)
                    .font(.title2.bold())
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(connection.arrivalTime.mhdTimeString)
                    .font(.title2.bold())
                Spacer()
                delayBadge
            }

            HStack(spacing: 6) {
                ForEach(connection.segments.prefix(4)) { segment in
                    LineBadgeView(lineNumber: segment.lineNumber, lineType: segment.lineType)
                }
                if connection.segments.count > 4 {
                    Text("+\(connection.segments.count - 4)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 16) {
                Label(connection.formattedDuration, systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if connection.transfers > 0 {
                    Label(
                        connection.transfers == 1
                            ? String(localized: "1 přestup")
                            : String(localized: "\(connection.transfers) přestupy"),
                        systemImage: "arrow.triangle.2.circlepath"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                } else {
                    Label(String(localized: "Přímý"), systemImage: "arrow.right.circle")
                        .font(.subheadline)
                        .foregroundStyle(Color.appSuccess)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    @ViewBuilder
    private var delayBadge: some View {
        if connection.isDelayed, let delay = connection.delay {
            Text("+\(delay) min")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.appDanger)
                .clipShape(Capsule())
        } else if connection.isRealtime {
            Text(String(localized: "Včas"))
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.appSuccess)
                .clipShape(Capsule())
        } else {
            Label(String(localized: "Bez real-time dat"), systemImage: "exclamationmark.triangle")
                .font(.caption)
                .foregroundStyle(Color.appWarning)
        }
    }

    private var accessibilityDescription: String {
        "Odjezd \(connection.departureTime.mhdTimeString), příjezd \(connection.arrivalTime.mhdTimeString), " +
        "doba jízdy \(connection.formattedDuration), " +
        (connection.transfers == 0 ? "přímý spoj" : "\(connection.transfers) přestupy")
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(PreviewData.connections) { conn in
            ConnectionRowView(connection: conn)
        }
    }
    .padding()
}
