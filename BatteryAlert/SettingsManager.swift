import Foundation

class SettingsManager {
    private let defaults = UserDefaults.standard
    private let lowThresholdKey = "lowThreshold"
    private let highThresholdKey = "highThreshold"
    
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
    
    init() {
        // Set default values if not already set
        if defaults.integer(forKey: lowThresholdKey) == 0 {
            lowThreshold = 20
        }
        if defaults.integer(forKey: highThresholdKey) == 0 {
            highThreshold = 80
        }
    }
} 