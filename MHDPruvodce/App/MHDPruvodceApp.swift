import SwiftUI
import SwiftData

@main
struct MHDPruvodceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    // Shared managers injected as environment objects
    @StateObject private var locationManager   = LocationManager()
    @StateObject private var audioManager      = AudioManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var liveActivityManager = LiveActivityManager()

    @StateObject private var trackingManager: TrackingManager

    init() {
        let loc   = LocationManager()
        let audio = AudioManager()
        let notif = NotificationManager()
        _locationManager     = StateObject(wrappedValue: loc)
        _audioManager        = StateObject(wrappedValue: audio)
        _notificationManager = StateObject(wrappedValue: notif)
        _trackingManager     = StateObject(wrappedValue: TrackingManager(
            locationManager: loc,
            audioManager: audio,
            notificationManager: notif
        ))
        _liveActivityManager = StateObject(wrappedValue: LiveActivityManager())
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([SavedSearch.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView(locationManager: locationManager)
                .environmentObject(trackingManager)
                .environmentObject(liveActivityManager)
                .environmentObject(audioManager)
                .environmentObject(notificationManager)
                .task {
                    await notificationManager.requestAuthorization()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    @ObservedObject var locationManager: LocationManager

    var body: some View {
        SearchView(locationManager: locationManager)
    }
}
