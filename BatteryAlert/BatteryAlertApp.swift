import SwiftUI
import UserNotifications
import AppKit

@main
struct BatteryAlertApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusBarItem: NSStatusItem!
    var batteryMonitor: BatteryMonitor!
    var settingsManager: SettingsManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize settings
        settingsManager = SettingsManager()
        
        // Initialize battery monitor
        batteryMonitor = BatteryMonitor(settingsManager: settingsManager)
        
        // Setup status bar item
        setupStatusBar()
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    private func setupStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "battery.100", accessibilityDescription: "Battery Alert")
        }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Low Threshold: \(settingsManager.lowThreshold)%", action: #selector(showLowThresholdAlert), keyEquivalent: "l"))
        menu.addItem(NSMenuItem(title: "High Threshold: \(settingsManager.highThreshold)%", action: #selector(showHighThresholdAlert), keyEquivalent: "h"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusBarItem.menu = menu
    }
    
    @objc private func showLowThresholdAlert() {
        let alert = NSAlert()
        alert.messageText = "Set Low Battery Threshold"
        alert.informativeText = "Enter a value between 0 and 100"
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        input.stringValue = "\(settingsManager.lowThreshold)"
        alert.accessoryView = input
        
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let value = Int(input.stringValue), value >= 0 && value <= 100 {
                settingsManager.lowThreshold = value
                statusBarItem.menu?.item(at: 0)?.title = "Low Threshold: \(value)%"
            }
        }
    }
    
    @objc private func showHighThresholdAlert() {
        let alert = NSAlert()
        alert.messageText = "Set High Battery Threshold"
        alert.informativeText = "Enter a value between 0 and 100"
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        input.stringValue = "\(settingsManager.highThreshold)"
        alert.accessoryView = input
        
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let value = Int(input.stringValue), value >= 0 && value <= 100 {
                settingsManager.highThreshold = value
                statusBarItem.menu?.item(at: 1)?.title = "High Threshold: \(value)%"
            }
        }
    }
}
