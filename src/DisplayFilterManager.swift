import Foundation
import AppKit
import CoreGraphics
import SwiftUI

// MARK: - Overlay-free, color-accurate filter manager built on the hardware gamma table (Gamma LUT)
@MainActor
class DisplayFilterManager {
    static let shared = DisplayFilterManager()
    
    private var restWindow: NSWindow?
    private var keepAliveTimer: Timer?
    
    private init() {
        // Watch for display hot-plug and resolution changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenChanges),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        // Watch for system wake from sleep
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleScreenChanges),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        
        // Start a lightweight anti-reset heartbeat timer (fires every 2.5s and only refreshes the GPU LUT once)
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.syncHardwareLUT()
            }
        }
    }
    
    @objc private func handleScreenChanges() {
        updateFilter()
    }
    
    func updateFilter() {
        let appState = AppState.shared
        if appState.isEnabled {
            syncHardwareLUT()
        } else {
            restore()
        }
    }
    
    // Core: write the color look-up table (LUT) straight to the display hardware
    // No transparent full-screen window at all, so text black stays 100% pure with no washed-out or hazy look
    private func syncHardwareLUT() {
        let appState = AppState.shared
        guard appState.isEnabled else { return }
        
        let scales = appState.selectedPreset.colorScales(strength: Float(appState.filterStrength))
        let dimFactor = Float(1.0 - appState.dimStrength * 0.70)
        
        let sampleCount: UInt32 = 256
        var rTable = [CGGammaValue](repeating: 0, count: Int(sampleCount))
        var gTable = [CGGammaValue](repeating: 0, count: Int(sampleCount))
        var bTable = [CGGammaValue](repeating: 0, count: Int(sampleCount))
        
        for i in 0..<Int(sampleCount) {
            let t = Float(i) / Float(sampleCount - 1)
            // Key: at t = 0 (black) the output is always 0, so black stays pure black
            // At t = 1 (white highlights) the blue/green channels are lowered, giving whites a natural warm tint
            rTable[i] = min(1.0, max(0.0, t * scales.r * dimFactor))
            gTable[i] = min(1.0, max(0.0, t * scales.g * dimFactor))
            bTable[i] = min(1.0, max(0.0, t * scales.b * dimFactor))
        }
        
        // Get all active displays
        var displayCount: UInt32 = 0
        var displays = [CGDirectDisplayID](repeating: 0, count: 16)
        CGGetOnlineDisplayList(16, &displays, &displayCount)
        
        var appliedDisplays = Set<CGDirectDisplayID>()
        for i in 0..<Int(displayCount) {
            let dID = displays[i]
            CGSetDisplayTransferByTable(dID, sampleCount, &rTable, &gTable, &bTable)
            appliedDisplays.insert(dID)
        }
        
        // Make sure the main display is always set
        let mainID = CGMainDisplayID()
        if !appliedDisplays.contains(mainID) {
            CGSetDisplayTransferByTable(mainID, sampleCount, &rTable, &gTable, &bTable)
        }
    }
    
    // Restore the system's default color calibration
    func restore() {
        CGDisplayRestoreColorSyncSettings()
    }
    
    // MARK: - 20-20-20 full-screen eye-break overlay
    func showRestOverlay(duration: Int = 20) {
        guard restWindow == nil else { return }
        
        let screen = NSScreen.main ?? NSScreen.screens.first!
        let win = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        win.isOpaque = false
        win.backgroundColor = NSColor.black.withAlphaComponent(0.85)
        win.level = NSWindow.Level(Int(CGWindowLevelForKey(.screenSaverWindow)))
        win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        win.hasShadow = false
        
        let restView = RestReminderView(durationSeconds: duration) { [weak self] in
            self?.dismissRestOverlay()
        }
        win.contentView = NSHostingView(rootView: restView)
        win.makeKeyAndOrderFront(nil)
        
        self.restWindow = win
    }
    
    func dismissRestOverlay() {
        restWindow?.orderOut(nil)
        restWindow = nil
    }
}
