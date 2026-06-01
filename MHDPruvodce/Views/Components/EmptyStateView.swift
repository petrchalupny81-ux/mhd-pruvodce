import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .hapticTap()
            }
        }
        .padding(32)
    }
}

#Preview {
    EmptyStateView(
        systemImage: "tram.fill",
        title: "Žádné spoje nenalezeny",
        subtitle: "Zkuste jiný čas nebo trasu.",
        actionTitle: "Zkusit znovu",
        action: {}
    )
}
