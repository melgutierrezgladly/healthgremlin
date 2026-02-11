import SwiftUI
import AppKit

// MARK: - App Entry Point
// This is the main entry point for Health Gremlin.
// It uses MenuBarExtra (macOS 14+) to create a menu bar-only app.
// There's no main window — just the menu bar icon and its dropdown.

@main
struct HealthGremlinApp: App {
    // NSApplicationDelegateAdaptor lets us run setup code when the app launches.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // MenuBarExtra creates an icon in the macOS menu bar.
        // The label uses our custom gremlin icon loaded from the app bundle.
        // We reference "GremlinIcon" which we'll place directly in Resources.
        MenuBarExtra {
            MenuBarView()
        } label: {
            // Load from the app bundle's Resources folder (not the SPM resource bundle)
            // This approach works because our build script copies the icon there.
            let image: NSImage = {
                let bundlePath = Bundle.main.bundlePath
                let iconPath = "\(bundlePath)/Contents/Resources/gremlin-icon.png"
                if let img = NSImage(contentsOfFile: iconPath) {
                    img.size = NSSize(width: 18, height: 18)
                    img.isTemplate = true
                    return img
                }
                // Fallback to a system image if our icon can't be found
                return NSImage(systemSymbolName: "face.smiling.inverse", accessibilityDescription: "Health Gremlin")!
            }()
            Image(nsImage: image)
        }
    }
}

// MARK: - App Delegate
// Handles app-level setup that SwiftUI can't do directly.
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the dock icon — this app lives only in the menu bar.
        // LSUIElement in Info.plist handles this, but belt-and-suspenders.
        NSApp.setActivationPolicy(.accessory)

        // Start the reminder timer system.
        // This kicks off the 5-minute grace period, after which
        // all category timers begin firing with randomized intervals.
        //
        // DEBUG: Set debugMode = true for 30x faster timers during testing.
        // (30 min water timer becomes ~1 min, 5 min grace becomes ~10 sec)
        // Read debug mode from UserDefaults (settings panel can toggle this)
        let debugMode = UserDefaults.standard.bool(forKey: "debugMode")
        TimerCoordinator.shared.debugMode = debugMode
        TimerCoordinator.shared.start()

        // Register global keyboard shortcuts for self-reporting
        HotkeyManager.shared.registerHotkeys()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Clean up hotkeys on quit
        HotkeyManager.shared.unregisterAll()
    }
}
