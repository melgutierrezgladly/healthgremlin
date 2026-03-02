import SwiftUI
import AppKit

// MARK: - Menu Bar Dropdown View
// This is what appears when you click the gremlin icon in the menu bar.
// Now wired to the real TimerCoordinator for pause/resume.

struct MenuBarView: View {
    // Observe the TimerCoordinator so pause state stays in sync
    @ObservedObject private var timerCoordinator = TimerCoordinator.shared

    var body: some View {
        // --- Status ---
        Text(timerCoordinator.isPaused ? "⏸ Reminders Paused" : "✅ Reminders Active")
            .font(.headline)

        if timerCoordinator.debugMode {
            Text("🧪 Debug Mode (30x speed)")
                .font(.caption)
                .foregroundColor(.orange)
        }

        if UserDefaults.standard.bool(forKey: "coworkingMode") {
            Text("🏢 Coworking Mode")
                .font(.caption)
                .foregroundColor(.blue)
        }

        Divider()

        // --- Pause/Resume ---
        if timerCoordinator.isPaused {
            Button("▶ Resume Reminders") {
                timerCoordinator.resume()
            }
        } else {
            Menu("⏸ Pause Reminders") {
                Button("15 minutes") {
                    timerCoordinator.pause(forDuration: 15 * 60)
                }
                Button("30 minutes") {
                    timerCoordinator.pause(forDuration: 30 * 60)
                }
                Button("1 hour") {
                    timerCoordinator.pause(forDuration: 60 * 60)
                }
                Button("Until resumed") {
                    timerCoordinator.pause()
                }
            }
        }

        Divider()

        // --- Demo Mode ---
        Menu("🎬 Demo Mode") {
            Text("Show all 3 escalation tiers:")
                .font(.caption)

            Button("💧 Water") {
                timerCoordinator.startDemo(category: .water)
            }
            Button("🧍 Stand/Sit") {
                timerCoordinator.startDemo(category: .standSit)
            }
            Button("🚶 Walk") {
                timerCoordinator.startDemo(category: .walk)
            }
            Button("💃 Dance") {
                timerCoordinator.startDemo(category: .dance)
            }
            .disabled(!ReminderCategory.dance.isCurrentlyActive)
            Button("💪 Calisthenics") {
                timerCoordinator.startDemo(category: .calisthenics)
            }
            .disabled(!ReminderCategory.calisthenics.isCurrentlyActive)
        }
        .disabled(timerCoordinator.inDemoMode || WindowManager.shared.isShowingReminder)

        // --- Settings ---
        Button("⚙ Settings...") {
            openSettings()
        }

        Divider()

        // --- Quit ---
        Button("✕ Quit Health Gremlin") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    // MARK: - Open Settings Window

    /// Opens the settings panel in a standalone window.
    /// Since we're a menu bar app (no main window), we create one manually.
    ///
    /// IMPORTANT: We temporarily switch from .accessory to .regular activation
    /// policy while the settings window is open. This is required because
    /// .accessory apps don't receive keyboard events, which breaks the
    /// hotkey recorder fields. When the window closes, we switch back.
    private func openSettings() {
        // Check if a settings window is already open
        if let existingWindow = NSApp.windows.first(where: { $0.title == "Health Gremlin Settings" }) {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Switch to .regular so the window gets full keyboard event access.
        // This makes the app briefly appear in the dock, but it's necessary
        // for the hotkey recorder to capture key combos.
        NSApp.setActivationPolicy(.regular)

        // Create a new window for the settings view
        let settingsView = SettingsView()
        let hostingView = NSHostingView(rootView: settingsView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 720),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Health Gremlin Settings"
        window.contentView = hostingView
        window.center()
        window.isReleasedWhenClosed = false

        // Set up a delegate to switch back to .accessory when the window closes
        let delegate = SettingsWindowDelegate()
        window.delegate = delegate
        // Store the delegate so it doesn't get deallocated
        SettingsWindowDelegate.current = delegate

        window.makeKeyAndOrderFront(nil)

        // Bring our app to the foreground so the settings window is visible
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - SettingsWindowDelegate
// Watches for the settings window closing so we can switch back
// to .accessory activation policy (no dock icon).

class SettingsWindowDelegate: NSObject, NSWindowDelegate {
    // Strong reference to keep the delegate alive while the window is open
    static var current: SettingsWindowDelegate?

    func windowWillClose(_ notification: Notification) {
        // Cancel any active hotkey recording
        HotkeyRecorderCoordinator.shared.stopRecording(cancelled: true)

        // Switch back to accessory mode (no dock icon)
        // Use a slight delay so the close animation finishes first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.setActivationPolicy(.accessory)
            SettingsWindowDelegate.current = nil
        }
    }
}
