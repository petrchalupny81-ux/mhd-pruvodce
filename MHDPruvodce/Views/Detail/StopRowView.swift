import SwiftUI

struct StopRowView: View {
    let stopTime: StopTime
    let isTransfer: Bool
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            timeColumn
            stopInfo
            Spacer()
            selectionButton
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(isSelected ? Color.appPrimary.opacity(0.08) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }

    private var timeColumn: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(stopTime.scheduledTime.mhdTimeString)
                .font(.subheadline.bold())
                .foregroundStyle(isTransfer ? Color.primary : .secondary)
            if stopTime.isDelayed, let actual = stopTime.actualTime {
                Text(actual.mhdTimeString)
                    .font(.caption.bold())
                    .foregroundStyle(Color.appWarning)
            }
        }
        .frame(width: 50, alignment: .trailing)
    }

    private var stopInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(stopTime.stop.name)
                .font(isTransfer ? .headline : .body)
                .foregroundStyle(.primary)
            if let platform = stopTime.platform {
                Text(String(localized: "Nástupiště \(platform)"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var selectionButton: some View {
        Button(action: onSelect) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Color.appPrimary : Color(.tertiaryLabel))
                .font(.title3)
        }
        .hapticTap(style: .light)
    }
}

#Preview {
    VStack {
        StopRowView(
            stopTime: StopTime(
                id: "1",
                stop: PreviewData.stops[0],
                scheduledTime: .now,
                actualTime: Date().addingTimeInterval(180),
                platform: "2"
            ),
            isTransfer: true,
            isSelected: true,
            onSelect: {}
        )
        StopRowView(
            stopTime: StopTime(
                id: "2",
                stop: PreviewData.stops[1],
                scheduledTime: .now.addingTimeInterval(600),
                actualTime: nil,
                platform: nil
            ),
            isTransfer: false,
            isSelected: false,
            onSelect: {}
        )
    }
    .padding()
}
