import SwiftUI
import MapKit
import CoreLocation

struct TrackingMapView: View {
    let userLocation: CLLocationCoordinate2D?
    let targetStop: Stop?

    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $cameraPosition) {
            if let user = userLocation {
                Annotation(String(localized: "Vy"), coordinate: user) {
                    Circle()
                        .fill(Color.appPrimary)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
            }
            if let stop = targetStop, let coord = stop.coordinate {
                Annotation(stop.name, coordinate: coord) {
                    VStack(spacing: 2) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(Color.appDanger)
                            .font(.title2)
                        Text(stop.name)
                            .font(.caption2.bold())
                            .padding(3)
                            .background(.regularMaterial)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear { updateCamera() }
        .onChange(of: userLocation?.latitude) { _, _ in updateCamera() }
        .onChange(of: userLocation?.longitude) { _, _ in updateCamera() }
    }

    private func updateCamera() {
        if let user = userLocation {
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: user,
                    latitudinalMeters: 800,
                    longitudinalMeters: 800
                ))
            }
        } else if let stop = targetStop, let coord = stop.coordinate {
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: coord,
                    latitudinalMeters: 800,
                    longitudinalMeters: 800
                ))
            }
        }
    }
}

#Preview {
    TrackingMapView(
        userLocation: CLLocationCoordinate2D(latitude: 50.075, longitude: 14.437),
        targetStop: PreviewData.stops[0]
    )
    .frame(height: 200)
    .padding()
}
