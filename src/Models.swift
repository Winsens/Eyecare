import Foundation
import SwiftUI
import AppKit

// MARK: - Eye-care preset modes
enum PresetMode: String, CaseIterable, Identifiable {
    case warm = "Daily Warm"
    case deep = "Deep Care"
    case candle = "Candlelight"
    case paper = "Soft Green"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .warm: return "sun.max.fill"
        case .deep: return "moon.stars.fill"
        case .candle: return "flame.fill"
        case .paper: return "leaf.fill"
        }
    }
    
    var subtitle: String {
        switch self {
        case .warm: return "~3400K soft warm light, for documents and coding"
        case .deep: return "~2700K amber, strong relief for dry, tired eyes"
        case .candle: return "~1900K candlelight, for late nights in low light"
        case .paper: return "Classic soft green, as calming as paper"
        }
    }
    
    // Compute (Red, Green, Blue) attenuation factors for the hardware LUT
    // Key point: only reduce high-energy blue/green light and never lift the black level, so text stays 100% pure black and sharp
    func colorScales(strength: Float) -> (r: Float, g: Float, b: Float) {
        let s = max(0.05, min(0.95, strength))
        switch self {
        case .warm:
            // Moderate blue reduction, slight green tweak, keeps very high text contrast
            return (1.0, 1.0 - s * 0.15, 1.0 - s * 0.55)
        case .deep:
            // Strong blue reduction, warm amber tone
            return (1.0, 1.0 - s * 0.30, 1.0 - s * 0.85)
        case .candle:
            // Very deep candlelight mode, removes harmful high-frequency blue light entirely
            return (1.0, 1.0 - s * 0.48, 1.0 - s * 0.98)
        case .paper:
            // Soft green paper mode: lower red and blue together so green stands out
            return (1.0 - s * 0.28, 1.0, 1.0 - s * 0.38)
        }
    }
    
    var defaultStrength: Double {
        switch self {
        case .warm: return 0.35
        case .deep: return 0.50
        case .candle: return 0.65
        case .paper: return 0.35
        }
    }
}

// MARK: - Global state
@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    // Master switch
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "isEnabled")
            DisplayFilterManager.shared.updateFilter()
        }
    }
    
    // Currently selected preset
    @Published var selectedPreset: PresetMode {
        didSet {
            UserDefaults.standard.set(selectedPreset.rawValue, forKey: "selectedPreset")
            filterStrength = selectedPreset.defaultStrength
            DisplayFilterManager.shared.updateFilter()
        }
    }
    
    // Blue-light filter strength (0.10 ~ 0.90)
    @Published var filterStrength: Double {
        didSet {
            UserDefaults.standard.set(filterStrength, forKey: "filterStrength")
            DisplayFilterManager.shared.updateFilter()
        }
    }
    
    // Deep screen dimming (0.0 ~ 0.50)
    @Published var dimStrength: Double {
        didSet {
            UserDefaults.standard.set(dimStrength, forKey: "dimStrength")
            DisplayFilterManager.shared.updateFilter()
        }
    }
    
    // 20-20-20 eye-break reminder
    @Published var isTimerEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isTimerEnabled, forKey: "isTimerEnabled")
            RestTimerManager.shared.syncTimerState()
        }
    }
    
    @Published var timerIntervalMinutes: Int {
        didSet {
            UserDefaults.standard.set(timerIntervalMinutes, forKey: "timerIntervalMinutes")
            RestTimerManager.shared.syncTimerState()
        }
    }
    
    @Published var secondsUntilNextRest: Int = 1200
    
    // Launch at login
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            AppLaunchManager.setLaunchAtLogin(launchAtLogin)
        }
    }
    
    private init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            "isEnabled": true,
            "selectedPreset": PresetMode.warm.rawValue,
            "filterStrength": 0.35,
            "dimStrength": 0.0,
            "isTimerEnabled": true,
            "timerIntervalMinutes": 20,
            "launchAtLogin": true
        ])
        
        self.isEnabled = defaults.bool(forKey: "isEnabled")
        let savedPresetStr = defaults.string(forKey: "selectedPreset") ?? PresetMode.warm.rawValue
        self.selectedPreset = PresetMode(rawValue: savedPresetStr) ?? .warm
        self.filterStrength = defaults.double(forKey: "filterStrength")
        self.dimStrength = defaults.double(forKey: "dimStrength")
        self.isTimerEnabled = defaults.bool(forKey: "isTimerEnabled")
        self.timerIntervalMinutes = defaults.integer(forKey: "timerIntervalMinutes")
        self.launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        self.secondsUntilNextRest = self.timerIntervalMinutes * 60
    }
}
