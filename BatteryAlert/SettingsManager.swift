import Foundation

class SettingsManager {
    private let defaults = UserDefaults.standard
    private let lowThresholdKey = "lowThreshold"
    private let highThresholdKey = "highThreshold"
    private let checkIntervalKey = "checkInterval"
    private let soundEnabledKey = "soundEnabled"
    
    // Default values
    private let defaultLowThreshold = 21
    private let defaultHighThreshold = 79
    private let defaultCheckInterval: TimeInterval = 60
    private let minimumCheckInterval: TimeInterval = 30
    
    var lowThreshold: Int {
        get {
            let value = defaults.integer(forKey: lowThresholdKey)
            return value > 0 ? min(max(value, 1), 99) : defaultLowThreshold
        }
        set {
            let validValue = min(max(newValue, 1), 99)
            defaults.set(validValue, forKey: lowThresholdKey)
        }
    }
    
    var highThreshold: Int {
        get {
            let value = defaults.integer(forKey: highThresholdKey)
            return value > 0 ? min(max(value, 1), 99) : defaultHighThreshold
        }
        set {
            let validValue = min(max(newValue, 1), 99)
            defaults.set(validValue, forKey: highThresholdKey)
        }
    }
    
    var checkInterval: TimeInterval {
        get {
            let interval = defaults.double(forKey: checkIntervalKey)
            return interval > 0 ? max(interval, minimumCheckInterval) : defaultCheckInterval
        }
        set {
            let validInterval = max(newValue, minimumCheckInterval)
            defaults.set(validInterval, forKey: checkIntervalKey)
        }
    }
    
    var soundEnabled: Bool {
        get {
            return defaults.bool(forKey: soundEnabledKey)
        }
        set {
            defaults.set(newValue, forKey: soundEnabledKey)
        }
    }
    
    init() {
        // Set default values if not already set
        if defaults.integer(forKey: lowThresholdKey) == 0 {
            lowThreshold = defaultLowThreshold
        }
        if defaults.integer(forKey: highThresholdKey) == 0 {
            highThreshold = defaultHighThreshold
        }
        if defaults.double(forKey: checkIntervalKey) == 0 {
            checkInterval = defaultCheckInterval
        }
        if defaults.object(forKey: soundEnabledKey) == nil {
            soundEnabled = true // Enable sound by default
        }
        
        // Ensure high threshold is always greater than low threshold
        if highThreshold <= lowThreshold {
            highThreshold = max(lowThreshold + 10, defaultHighThreshold)
        }
    }
} 