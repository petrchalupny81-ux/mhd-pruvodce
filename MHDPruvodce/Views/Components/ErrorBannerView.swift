import SwiftUI

struct ErrorBannerView: View {
    let error: NetworkError
    let retryAction: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.white)
            Text(error.errorDescription ?? String(localized: "Nastala chyba."))
                .font(.subheadline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
            Spacer()
            if let retry = retryAction {
                Button(String(localized: "Zkusit znovu"), action: retry)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .hapticTap()
            }
        }
        .padding()
        .background(Color.appDanger)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

#Preview {
    ErrorBannerView(error: .noInternet, retryAction: {})
        .padding()
}
