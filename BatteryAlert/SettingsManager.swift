import Foundation

class SettingsManager {
    private let defaults = UserDefaults.standard
    private let lowThresholdKey = "lowThreshold"
    private let highThresholdKey = "highThreshold"
    private let checkIntervalKey = "checkInterval"
    
    var lowThreshold: Int {
        get {
            return defaults.integer(forKey: lowThresholdKey)
        }
        set {
            defaults.set(newValue, forKey: lowThresholdKey)
        }
    }
    
    var highThreshold: Int {
        get {
            return defaults.integer(forKey: highThresholdKey)
        }
        set {
            defaults.set(newValue, forKey: highThresholdKey)
        }
    }
    
    var checkInterval: TimeInterval {
        get {
            let interval = defaults.double(forKey: checkIntervalKey)
            return interval > 0 ? interval : 60 // Default to 1 minute if not set
        }
        set {
            defaults.set(newValue, forKey: checkIntervalKey)
        }
    }
    
    init() {
        // Set default values if not already set
        if defaults.integer(forKey: lowThresholdKey) == 0 {
            lowThreshold = 20
        }
        if defaults.integer(forKey: highThresholdKey) == 0 {
            highThreshold = 80
        }
        if defaults.double(forKey: checkIntervalKey) == 0 {
            checkInterval = 60 // Default to 1 minute
        }
    }
} 