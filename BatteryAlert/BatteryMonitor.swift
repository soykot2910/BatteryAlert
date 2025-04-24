import Foundation
import IOKit.ps
import UserNotifications
import AppKit

class BatteryMonitor {
    private var timer: Timer?
    private let settingsManager: SettingsManager
    private var lastNotificationType: NotificationType?
    private var isMonitoring = false
    
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
        guard !isMonitoring else { return }
        stopMonitoring()
        
        // Validate check interval
        let interval = max(30, settingsManager.checkInterval) // Ensure minimum 30 seconds
        
        // Create new timer with current interval setting
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkBatteryStatus()
        }
        timer?.tolerance = 1.0 // Add some tolerance to help with power efficiency
        timer?.fire() // Check immediately
        isMonitoring = true
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
    }
    
    func updateCheckInterval() {
        // Restart monitoring with new interval
        startMonitoring()
    }
    
    private func checkBatteryStatus() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            print("Error: Could not get power source info")
            return
        }
        
        guard let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else {
            print("Error: Could not get power source list")
            return
        }
        
        for source in sources {
            guard let info = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] else {
                continue
            }
            
            if let capacity = info[kIOPSCurrentCapacityKey] as? Int,
               let isCharging = info[kIOPSPowerSourceStateKey] as? String {
                
                let charging = isCharging == kIOPSACPowerValue
                
                // Check low battery threshold
                if capacity <= settingsManager.lowThreshold && !charging && lastNotificationType != .low {
                    showNotification(title: "Low Battery Alert", body: "Battery level is at \(capacity)%. Please plug in the charger.")
                    lastNotificationType = .low
                }
                
                // Check high battery threshold
                if capacity >= settingsManager.highThreshold && charging && lastNotificationType != .high {
                    showNotification(title: "High Battery Alert", body: "Battery level is at \(capacity)%. Consider unplugging the charger.")
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
        
        // Configure sound if enabled
        if settingsManager.soundEnabled {
            content.sound = UNNotificationSound.default
        }
        
        // Add a unique identifier based on the notification type
        let identifier = "BatteryAlert-\(UUID().uuidString)"
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error.localizedDescription)")
            }
        }
        
        // Show system alert
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = body
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            
            // Make the alert appear on top of other windows
            alert.window.level = .floating
            
            // Play system alert sound if enabled
            if self.settingsManager.soundEnabled {
                NSSound(named: "Sosumi")?.play()
            }
            
            alert.runModal()
        }
    }
} 