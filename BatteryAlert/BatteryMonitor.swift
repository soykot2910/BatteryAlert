import Foundation
import IOKit.ps
import UserNotifications

class BatteryMonitor {
    private var timer: Timer?
    private let settingsManager: SettingsManager
    private var lastNotificationType: NotificationType?
    
    enum NotificationType {
        case low
        case high
    }
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        stopMonitoring() // Stop any existing timer
        
        // Create new timer with current interval setting
        timer = Timer.scheduledTimer(withTimeInterval: settingsManager.checkInterval, repeats: true) { [weak self] _ in
            self?.checkBatteryStatus()
        }
        timer?.fire() // Check immediately
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateCheckInterval() {
        // Restart monitoring with new interval
        startMonitoring()
    }
    
    private func checkBatteryStatus() {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        
        for source in sources {
            let info = IOPSGetPowerSourceDescription(snapshot, source).takeRetainedValue() as NSDictionary
            
            if let capacity = info[kIOPSCurrentCapacityKey] as? Int,
               let isCharging = info[kIOPSPowerSourceStateKey] as? String {
                
                let charging = isCharging == kIOPSACPowerValue
                
                // Check low battery threshold
                if capacity <= settingsManager.lowThreshold && !charging && lastNotificationType != .low {
                    showNotification(title: "Low Battery", body: "Please plug in the charger")
                    lastNotificationType = .low
                }
                
                // Check high battery threshold
                if capacity >= settingsManager.highThreshold && charging && lastNotificationType != .high {
                    showNotification(title: "High Battery", body: "Please unplug the charger")
                    lastNotificationType = .high
                }
                
                // Reset notification type if battery is in normal range
                if capacity > settingsManager.lowThreshold && capacity < settingsManager.highThreshold {
                    lastNotificationType = nil
                }
            }
        }
    }
    
    private func showNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error.localizedDescription)")
            }
        }
    }
} 