import Foundation
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Set up the menu bar status icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            if let image = NSImage(systemSymbolName: "eye.fill", accessibilityDescription: "Eyecare") {
                image.isTemplate = true
                button.image = image
            }
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
        
        // 2. Initialize the SwiftUI popover panel
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 440)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())
        self.popover = popover
        
        // 3. Activate hardware LUT dimming and the timer
        Task { @MainActor in
            DisplayFilterManager.shared.updateFilter()
            RestTimerManager.shared.syncTimerState()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Make sure the system ColorSync colors are restored on quit
        Task { @MainActor in
            DisplayFilterManager.shared.restore()
        }
    }
    
    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
