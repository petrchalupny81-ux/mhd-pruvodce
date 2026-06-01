import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, ObservableObject {
    @Published var isAuthorized = false

    static let categoryID = "TRANSPORT_ALERT"
    static let actionShowJourney = "SHOW_JOURNEY"

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        registerCategory()
        Task { await checkAuthorization() }
    }

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
        } catch {
            isAuthorized = false
        }
    }

    func scheduleAlert(
        timing: AlertTiming,
        stopName: String,
        lineName: String,
        direction: String,
        triggerDate: Date
    ) {
        let content = UNMutableNotificationContent()
        content.title = "🚌 Přijíždíte za \(timing.minutesBefore) minut"
        content.body = "Zastávka: \(stopName) — \(lineName) směr \(direction)"
        content.sound = .default
        content.categoryIdentifier = Self.categoryID

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let id = "mhd-\(timing.rawValue)-\(stopName)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleProximityAlert(
        timing: AlertTiming,
        stopName: String,
        lineName: String,
        direction: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = timing == .atStop ? "🚌 Nastupujte!" : "🚌 Přijíždíte za \(timing.minutesBefore) min"
        content.body = "Zastávka: \(stopName) — \(lineName) směr \(direction)"
        content.sound = .default
        content.categoryIdentifier = Self.categoryID

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let id = "mhd-proximity-\(timing.rawValue)-\(stopName)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelAllJourneyNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Private

    private func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    private func registerCategory() {
        let showAction = UNNotificationAction(
            identifier: Self.actionShowJourney,
            title: "Zobrazit spoj",
            options: .foreground
        )
        let category = UNNotificationCategory(
            identifier: Self.categoryID,
            actions: [showAction],
            intentIdentifiers: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        // Deep link to ActiveTrackingView handled via scene state
    }
}
