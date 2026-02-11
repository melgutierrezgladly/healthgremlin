import Cocoa
import Carbon

// MARK: - HotkeyManager
// Registers global keyboard shortcuts so the user can self-report
// activities from anywhere on their Mac — even when another app has focus.
//
// HOW GLOBAL HOTKEYS WORK ON macOS:
// We use Carbon's RegisterEventHotKey API (yes, it's old, but it's
// the most reliable way to do global hotkeys without accessibility
// permissions). Each hotkey gets a unique ID, and when pressed,
// macOS sends us a Carbon event which we handle.
//
// DEFAULT SHORTCUTS (customizable in Settings):
// ⌘ + Shift + S → "I just stood up" (resets stand/sit timer)
// ⌘ + Shift + D → "I just sat down" (resets stand/sit timer)
// ⌘ + Shift + W → "I just drank water" (resets water timer)
// ⌘ + Shift + K → "I just walked/moved" (resets walk timer)
// ⌘ + Shift + P → Pause/resume all reminders
//
// Users can customize these shortcuts in Settings using the
// hotkey recorder. Custom shortcuts are stored in UserDefaults
// via HotkeyConfig.

class HotkeyManager {
    static let shared = HotkeyManager()

    // Store references to registered hotkeys so we can unregister later
    private var hotkeyRefs: [EventHotKeyRef?] = []

    // Map from Carbon hotkey IDs to our action names
    // This lets us look up which action to perform when a hotkey fires.
    private var idToAction: [UInt32: String] = [:]

    // Unique ID counter — each registered hotkey gets a unique numeric ID
    private var nextID: UInt32 = 1

    // Whether the Carbon event handler has been installed
    // (we only need to install it once, even if we re-register hotkeys)
    private var handlerInstalled = false

    // Brief approving quips for when the user self-reports
    private let quips = [
        "Noted. Well done, ma'am.",
        "Excellent initiative. I'll update your file.",
        "Self-sufficient. I respect that.",
        "Acknowledged. Gold star for you.",
        "Proactive! I'm almost out of a job.",
        "Noted with admiration.",
    ]

    private init() {}

    // MARK: - Register all hotkeys

    /// Call this on app launch (and whenever shortcuts change in Settings)
    /// to register all global keyboard shortcuts from the user's config.
    @discardableResult
    func registerHotkeys() -> Bool {
        // Unregister any existing hotkeys first (safe to call even if none registered)
        unregisterAll()

        // Install the Carbon event handler (only once)
        if !handlerInstalled {
            installCarbonEventHandler()
            handlerInstalled = true
        }

        // Load the user's custom hotkey configs (falls back to defaults)
        let configs = HotkeyConfig.loadAll()

        var success = true

        // Register each configured shortcut
        for (actionName, config) in configs {
            let registered = register(
                keyCode: config.keyCode,
                modifiers: config.modifiers,
                actionName: actionName
            )
            success = registered && success
        }

        if success {
            print("⌨️ All global hotkeys registered successfully")
        } else {
            print("⚠️ Some hotkeys failed to register — they may conflict with other apps")
        }

        return success
    }

    // MARK: - Register a single hotkey

    private func register(keyCode: UInt32, modifiers: UInt32, actionName: String) -> Bool {
        let id = nextID
        nextID += 1

        var hotkeyRef: EventHotKeyRef?
        let hotkeyID = EventHotKeyID(
            signature: OSType(0x4847_524D), // "HGRM" in hex — our app signature
            id: id
        )

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef
        )

        if status == noErr {
            hotkeyRefs.append(hotkeyRef)
            idToAction[id] = actionName
            return true
        } else {
            print("⚠️ Failed to register hotkey '\(actionName)' — status: \(status)")
            return false
        }
    }

    // MARK: - Carbon event handler

    /// Installs a Carbon event handler that catches all hotkey events.
    /// When a registered hotkey is pressed, this handler is called.
    private func installCarbonEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        // The handler is a C function pointer — we use a closure-like pattern
        // by passing `self` as userData and using a global function.
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                // Extract which hotkey was pressed
                var hotkeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotkeyID
                )

                guard status == noErr else { return status }

                // Dispatch to the appropriate handler on the main thread
                DispatchQueue.main.async {
                    HotkeyManager.shared.handleHotkey(id: hotkeyID.id)
                }

                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
    }

    // MARK: - Handle hotkey press

    /// Called when any of our registered hotkeys is pressed.
    /// Looks up the action name from our ID map and performs it.
    private func handleHotkey(id: UInt32) {
        guard let actionName = idToAction[id] else { return }

        switch actionName {
        case "stood":
            print("⌨️ Hotkey: Stood up")
            TimerCoordinator.shared.selfReport(category: .standSit)
            showQuip()

        case "sat":
            print("⌨️ Hotkey: Sat down")
            TimerCoordinator.shared.selfReport(category: .standSit)
            showQuip()

        case "water":
            print("⌨️ Hotkey: Drank water")
            TimerCoordinator.shared.selfReport(category: .water)
            showQuip()

        case "walked":
            print("⌨️ Hotkey: Walked/moved")
            TimerCoordinator.shared.selfReport(category: .walk)
            showQuip()

        case "pauseResume":
            print("⌨️ Hotkey: Pause/Resume")
            if TimerCoordinator.shared.isPaused {
                TimerCoordinator.shared.resume()
            } else {
                TimerCoordinator.shared.pause()
            }

        default:
            print("⌨️ Unknown hotkey action: \(actionName)")
        }
    }

    // MARK: - Show approving quip

    /// Briefly shows the gremlin with an approving message when the user
    /// self-reports an activity. Disappears after 2 seconds.
    private func showQuip() {
        let quip = quips.randomElement()!

        // Show the quip as a Tier 1 (friendly JARVIS) message
        WindowManager.shared.showReminder(
            message: quip,
            category: "👍 Nice work!",
            tier: 1
        )

        // Clear any button callbacks — quips aren't actionable
        WindowManager.shared.onAcknowledge = nil
        WindowManager.shared.onDelay = nil

        // Auto-dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            WindowManager.shared.dismissReminder()
        }
    }

    // MARK: - Cleanup

    /// Unregister all hotkeys (call on app quit or before re-registering)
    func unregisterAll() {
        for ref in hotkeyRefs {
            if let ref = ref {
                UnregisterEventHotKey(ref)
            }
        }
        hotkeyRefs.removeAll()
        idToAction.removeAll()
        nextID = 1
        print("⌨️ All hotkeys unregistered")
    }
}
