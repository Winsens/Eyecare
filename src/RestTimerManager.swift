import Foundation
import UserNotifications
import ServiceManagement

// MARK: - Eye-break reminder timer manager
@MainActor
class RestTimerManager {
    static let shared = RestTimerManager()
    
    private var timer: Timer?
    
    private init() {
        requestNotificationPermission()
        syncTimerState()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    func syncTimerState() {
        timer?.invalidate()
        timer = nil
        
        let appState = AppState.shared
        guard appState.isTimerEnabled else { return }
        
        // Reset the countdown
        appState.secondsUntilNextRest = appState.timerIntervalMinutes * 60
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    private func tick() {
        let appState = AppState.shared
        guard appState.isTimerEnabled else { return }
        
        if appState.secondsUntilNextRest > 1 {
            appState.secondsUntilNextRest -= 1
        } else {
            // Trigger the eye-break reminder
            appState.secondsUntilNextRest = appState.timerIntervalMinutes * 60
            DisplayFilterManager.shared.showRestOverlay(duration: 20)
            sendNotification()
        }
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Eyecare: Time for an Eye Break"
        content.body = "You've been working for a while. Look up, blink a few times, and gaze into the distance for 20 seconds to relax your eye muscles."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Launch-at-login manager
class AppLaunchManager {
    static func setLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    if SMAppService.mainApp.status != .enabled {
                        try SMAppService.mainApp.register()
                    }
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                    }
                }
            } catch {
                print("Failed to set launch at login:", error)
            }
        }
    }
}
