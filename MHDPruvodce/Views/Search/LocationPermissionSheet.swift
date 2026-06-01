import SwiftUI
import UIKit

struct LocationPermissionSheet: View {
    @ObservedObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "location.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.appPrimary)
                .padding(.top, 32)

            VStack(spacing: 12) {
                Text(String(localized: "Povolte přístup k poloze"))
                    .font(.title2.bold())
                Text(String(localized: "MHD Průvodce potřebuje vaši polohu, aby vás mohl upozornit před příjezdem na zastávku — i když je aplikace na pozadí."))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 12) {
                featureRow(
                    icon: "bell.fill",
                    color: .appPrimary,
                    title: String(localized: "Upozornění před zastávkou"),
                    subtitle: String(localized: "Dostanete vibrace a zvuk (se sluchátky) v pravý čas")
                )
                featureRow(
                    icon: "battery.75",
                    color: .appSuccess,
                    title: String(localized: "Šetří baterii"),
                    subtitle: String(localized: "Poloha se sleduje jen během aktivní jízdy")
                )
                featureRow(
                    icon: "lock.shield.fill",
                    color: .secondary,
                    title: String(localized: "Vaše data jsou soukromá"),
                    subtitle: String(localized: "Poloha se nikam neodesílá")
                )
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                switch locationManager.authStatus {
                case .notDetermined:
                    Button {
                        locationManager.requestAlwaysAuthorization()
                        dismiss()
                    } label: {
                        Text(String(localized: "Povolit polohu vždy"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appPrimary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .hapticTap(style: .medium)

                    Button(String(localized: "Jen při používání")) {
                        locationManager.requestWhenInUseAuthorization()
                        dismiss()
                    }
                    .foregroundStyle(.secondary)

                case .denied, .restricted:
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    } label: {
                        Text(String(localized: "Otevřít Nastavení"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appPrimary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .hapticTap(style: .medium)

                case .whenInUse:
                    VStack(spacing: 8) {
                        Text(String(localized: "Máte povolenou polohu jen při použití."))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                openURL(url)
                            }
                        } label: {
                            Text(String(localized: "Povolit vždy v Nastavení"))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appWarning)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }

                case .always:
                    Label(String(localized: "Poloha povolena"), systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Color.appSuccess)
                        .font(.headline)
                        .onAppear { dismiss() }
                }

                Button(String(localized: "Nyní ne")) { dismiss() }
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }

    private func featureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    LocationPermissionSheet(locationManager: LocationManager())
}
