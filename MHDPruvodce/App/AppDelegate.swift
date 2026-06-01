import UIKit
import BackgroundTasks
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {
    static let bgRefreshID    = "cz.mhd.refresh"
    static let bgProcessingID = "cz.mhd.locationcheck"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        registerBackgroundTasks()
        return true
    }

    // MARK: - Background Tasks

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.bgRefreshID,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.bgProcessingID,
            using: nil
        ) { task in
            self.handleLocationCheck(task: task as! BGProcessingTask)
        }
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.bgRefreshID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    func scheduleLocationCheck() {
        let request = BGProcessingTaskRequest(identifier: Self.bgProcessingID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        try? BGTaskScheduler.shared.submit(request)
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        let workTask = Task {
            // Notify TrackingManager to check current position
            NotificationCenter.default.post(name: .mhdBackgroundRefresh, object: nil)
        }

        task.expirationHandler = {
            workTask.cancel()
        }

        Task {
            await workTask.value
            task.setTaskCompleted(success: true)
        }
    }

    private func handleLocationCheck(task: BGProcessingTask) {
        scheduleLocationCheck()

        let workTask = Task {
            NotificationCenter.default.post(name: .mhdBackgroundLocationCheck, object: nil)
        }

        task.expirationHandler = {
            workTask.cancel()
        }

        Task {
            await workTask.value
            task.setTaskCompleted(success: true)
        }
    }
}

extension Notification.Name {
    static let mhdBackgroundRefresh       = Notification.Name("mhdBackgroundRefresh")
    static let mhdBackgroundLocationCheck = Notification.Name("mhdBackgroundLocationCheck")
}
