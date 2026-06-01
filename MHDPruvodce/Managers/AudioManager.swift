import UIKit
import Foundation
import AVFoundation
import Combine

enum AlertSound: String {
    case far    = "alert_far"
    case near   = "alert_near"
    case arrive = "alert_arrive"
}

@MainActor
final class AudioManager: ObservableObject {
    @Published var headphonesConnected = false

    private var player: AVAudioPlayer?
    private var routeChangeObserver: NSObjectProtocol?

    init() {
        configureSession()
        updateHeadphoneStatus()
        startMonitoringRouteChanges()
    }

    deinit {
        if let obs = routeChangeObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }

    func playAlert(_ sound: AlertSound) {
        guard headphonesConnected else {
            triggerHaptic(style: .heavy)
            return
        }
        triggerHaptic(style: .heavy)
        playSound(sound)
    }

    func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    // MARK: - Private

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Audio session setup failure is non-fatal
        }
    }

    private func playSound(_ sound: AlertSound) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "caf") else {
            // Fall back to a system sound if the bundled .caf is missing
            AudioServicesPlaySystemSound(1016)
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            AudioServicesPlaySystemSound(1016)
        }
    }

    private func updateHeadphoneStatus() {
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        headphonesConnected = outputs.contains { port in
            [.headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE].contains(port.portType)
        }
    }

    private func startMonitoringRouteChanges() {
        routeChangeObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateHeadphoneStatus()
            }
        }
    }
}
