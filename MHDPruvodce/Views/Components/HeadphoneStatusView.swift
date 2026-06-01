import SwiftUI

struct HeadphoneStatusView: View {
    let connected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: connected ? "headphones" : "headphones.slash")
                .foregroundStyle(connected ? Color.appSuccess : Color.appWarning)
            Text(connected
                 ? String(localized: "Sluchátka připojena")
                 : String(localized: "Sluchátka odpojena – bez zvuku")
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

struct HeadphoneDisconnectedBannerView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "headphones.slash")
                .foregroundStyle(.white)
            Text(String(localized: "Sluchátka odpojena – zvukové upozornění bude při připojení"))
                .font(.subheadline)
                .foregroundStyle(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appWarning)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 20) {
        HeadphoneStatusView(connected: true)
        HeadphoneStatusView(connected: false)
        HeadphoneDisconnectedBannerView()
    }
    .padding()
}
