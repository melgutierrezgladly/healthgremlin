import SwiftUI
import AppKit
import Carbon

// MARK: - HotkeyRecorderView
// A clickable field that captures keyboard shortcuts.
//
// How it works:
// 1. User clicks the field → it enters "recording" mode (highlighted border)
// 2. Global hotkeys are temporarily unregistered so they don't intercept
// 3. A local event monitor captures the next key combo
// 4. The new shortcut is displayed, global hotkeys are re-registered
//
// REQUIRES: The settings window must open with .regular activation policy
// (handled by MenuBarView.openSettings). Without this, .accessory apps
// don't receive keyboard events at all.
//
// NOTE: Some key combos (like Ctrl+number) may be intercepted by macOS
// for Mission Control / Spaces switching before they reach any app.
// Those combos can't be used as shortcuts unless the user disables
// the corresponding macOS system shortcuts in System Settings.

struct HotkeyRecorderView: View {
    let label: String
    @Binding var config: HotkeyConfig
    @State private var isRecording = false

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 140, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isRecording ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor))
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isRecording ? Color.accentColor : Color(nsColor: .separatorColor),
                            lineWidth: isRecording ? 2 : 1)
                Text(isRecording ? "Press keys..." : config.displayString)
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundColor(isRecording ? .accentColor : .primary)
            }
            .frame(width: 120, height: 28)
            .contentShape(Rectangle())
            .onTapGesture {
                if isRecording {
                    HotkeyRecorderCoordinator.shared.stopRecording(cancelled: true)
                } else {
                    HotkeyRecorderCoordinator.shared.startRecording { keyCode, modifiers in
                        config = HotkeyConfig(keyCode: keyCode, modifiers: modifiers)
                        isRecording = false
                    } onCancelled: {
                        isRecording = false
                    }
                    isRecording = true
                }
            }
        }
    }
}

// MARK: - HotkeyRecorderCoordinator
// A singleton that manages the keyboard event capture process.
//
// Uses a local NSEvent monitor to capture key events. This works
// because the settings window opens with .regular activation policy,
// which means the app properly receives keyboard events.
//
// Only one recorder field can be active at a time — clicking a
// different field while one is recording cancels the first.

class HotkeyRecorderCoordinator {
    static let shared = HotkeyRecorderCoordinator()

    private var localMonitor: Any?
    private var onKeyRecorded: ((UInt32, UInt32) -> Void)?
    private var onCancelled: (() -> Void)?
    private(set) var isRecording = false

    private init() {}

    /// Start recording a keyboard shortcut.
    /// Unregisters global hotkeys and installs a local event monitor.
    func startRecording(
        onKeyRecorded: @escaping (UInt32, UInt32) -> Void,
        onCancelled: @escaping () -> Void
    ) {
        // Cancel any existing recording first
        if isRecording {
            stopRecording(cancelled: true)
        }

        self.onKeyRecorded = onKeyRecorded
        self.onCancelled = onCancelled
        self.isRecording = true

        // Unregister global hotkeys so they don't steal key combos
        HotkeyManager.shared.unregisterAll()

        // Make sure the settings window is key and frontmost
        if let window = NSApp.windows.first(where: { $0.title == "Health Gremlin Settings" }) {
            window.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)

        // Local event monitor — catches key events when our app is active.
        // Works because settings window opens with .regular activation policy.
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, self.isRecording else { return event }
            if self.processKeyEvent(event) {
                return nil // consumed
            }
            return event
        }
    }

    /// Process a key event. Returns true if consumed.
    private func processKeyEvent(_ event: NSEvent) -> Bool {
        // Escape cancels recording
        if event.keyCode == UInt16(kVK_Escape) {
            stopRecording(cancelled: true)
            return true
        }

        // We need at least one "real" modifier (⌘, ⌃, or ⌥).
        // Shift alone is not enough — it would conflict with normal typing.
        // Note: Some combos like Ctrl+number are grabbed by macOS for
        // Mission Control/Spaces and will never reach this handler.
        let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let hasModifier = modifierFlags.contains(.command) ||
                          modifierFlags.contains(.control) ||
                          modifierFlags.contains(.option)

        guard hasModifier else {
            return true // consume but ignore — no valid modifier
        }

        let keyCode = UInt32(event.keyCode)
        let carbonMods = HotkeyConfig.carbonModifiers(from: modifierFlags)

        // Capture the callback before cleanup
        let callback = onKeyRecorded

        // Stop recording (cleans up monitors, re-registers hotkeys)
        stopRecording(cancelled: false)

        // Fire the callback with the captured shortcut
        callback?(keyCode, carbonMods)

        return true
    }

    /// Stop recording, clean up monitors, re-register global hotkeys.
    func stopRecording(cancelled: Bool) {
        guard isRecording else { return }
        isRecording = false

        // Remove event monitor
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }

        // Re-register global hotkeys with current configs
        HotkeyManager.shared.registerHotkeys()

        // Notify if cancelled
        if cancelled {
            onCancelled?()
        }

        onKeyRecorded = nil
        onCancelled = nil
    }
}
