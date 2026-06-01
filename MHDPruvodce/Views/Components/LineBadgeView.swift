import SwiftUI

struct LineBadgeView: View {
    let lineNumber: String
    let lineType: LineType

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: lineType.icon)
                .font(.caption2)
            Text(lineNumber)
                .font(.caption.bold())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(lineType.color)
        .clipShape(Capsule())
    }
}

#Preview {
    HStack {
        LineBadgeView(lineNumber: "22", lineType: .tram)
        LineBadgeView(lineNumber: "A", lineType: .metro)
        LineBadgeView(lineNumber: "880", lineType: .train)
        LineBadgeView(lineNumber: "12", lineType: .bus)
    }
    .padding()
}
