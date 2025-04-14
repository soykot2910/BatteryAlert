import AppKit
import ServiceManagement

extension NSWorkspace {
    func setLaunchOnLogin(enabled: Bool, at url: URL) throws {
        if #available(macOS 13.0, *) {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } else {
            // Fallback for older macOS versions
            if enabled {
                try NSWorkspace.shared.launchApplication(at: url,
                                                       options: [.withoutActivation],
                                                       configuration: [:])
            }
        }
    }
} 