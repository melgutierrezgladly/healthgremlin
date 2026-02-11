import Foundation
import Carbon
import AppKit

// MARK: - HotkeyConfig
// Stores a user-configurable keyboard shortcut as a key code + modifier combo.
// Persists to UserDefaults so custom keybindings survive app restarts.
//
// Each shortcut has:
// - A keyCode (Carbon virtual key code, e.g. kVK_ANSI_S = 1)
// - Modifiers (bitmask of cmdKey, shiftKey, optionKey, controlKey)
// - A display string for showing in the UI (e.g. "⌘⇧S")

struct HotkeyConfig: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32  // Carbon modifier flags

    // MARK: - Default shortcuts (matching the spec)

    static let defaults: [String: HotkeyConfig] = [
        "stood":       HotkeyConfig(keyCode: UInt32(kVK_ANSI_S), modifiers: UInt32(cmdKey | shiftKey)),
        "sat":         HotkeyConfig(keyCode: UInt32(kVK_ANSI_D), modifiers: UInt32(cmdKey | shiftKey)),
        "water":       HotkeyConfig(keyCode: UInt32(kVK_ANSI_W), modifiers: UInt32(cmdKey | shiftKey)),
        "walked":      HotkeyConfig(keyCode: UInt32(kVK_ANSI_K), modifiers: UInt32(cmdKey | shiftKey)),
        "pauseResume": HotkeyConfig(keyCode: UInt32(kVK_ANSI_P), modifiers: UInt32(cmdKey | shiftKey)),
    ]

    // MARK: - Load/Save from UserDefaults

    /// Load all hotkey configs from UserDefaults, falling back to defaults
    static func loadAll() -> [String: HotkeyConfig] {
        guard let data = UserDefaults.standard.data(forKey: "hotkeyConfigs"),
              let configs = try? JSONDecoder().decode([String: HotkeyConfig].self, from: data) else {
            return defaults
        }
        // Merge with defaults so any new shortcuts added in updates are included
        var merged = defaults
        for (key, value) in configs {
            merged[key] = value
        }
        return merged
    }

    /// Save all hotkey configs to UserDefaults
    static func saveAll(_ configs: [String: HotkeyConfig]) {
        if let data = try? JSONEncoder().encode(configs) {
            UserDefaults.standard.set(data, forKey: "hotkeyConfigs")
        }
    }

    // MARK: - Display string

    /// Human-readable representation like "⌘⇧S"
    var displayString: String {
        var parts: [String] = []

        // Modifier symbols (in standard macOS order)
        if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        if modifiers & UInt32(optionKey) != 0  { parts.append("⌥") }
        if modifiers & UInt32(shiftKey) != 0   { parts.append("⇧") }
        if modifiers & UInt32(cmdKey) != 0     { parts.append("⌘") }

        // Key name
        parts.append(keyName(for: keyCode))

        return parts.joined()
    }

    /// Maps a Carbon key code to a readable key name
    private func keyName(for code: UInt32) -> String {
        switch Int(code) {
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        case kVK_F1:  return "F1"
        case kVK_F2:  return "F2"
        case kVK_F3:  return "F3"
        case kVK_F4:  return "F4"
        case kVK_F5:  return "F5"
        case kVK_F6:  return "F6"
        case kVK_F7:  return "F7"
        case kVK_F8:  return "F8"
        case kVK_F9:  return "F9"
        case kVK_F10: return "F10"
        case kVK_F11: return "F11"
        case kVK_F12: return "F12"
        case kVK_Space: return "Space"
        case kVK_Return: return "↩"
        case kVK_Tab: return "⇥"
        case kVK_Delete: return "⌫"
        case kVK_Escape: return "⎋"
        case kVK_UpArrow: return "↑"
        case kVK_DownArrow: return "↓"
        case kVK_LeftArrow: return "←"
        case kVK_RightArrow: return "→"
        default: return "Key\(code)"
        }
    }

    // MARK: - Convert NSEvent modifiers to Carbon modifiers

    /// Converts NSEvent modifier flags to Carbon modifier flags.
    /// NSEvent uses a different bitmask system than Carbon's RegisterEventHotKey.
    static func carbonModifiers(from nsFlags: NSEvent.ModifierFlags) -> UInt32 {
        var carbon: UInt32 = 0
        if nsFlags.contains(.command) { carbon |= UInt32(cmdKey) }
        if nsFlags.contains(.shift)   { carbon |= UInt32(shiftKey) }
        if nsFlags.contains(.option)  { carbon |= UInt32(optionKey) }
        if nsFlags.contains(.control) { carbon |= UInt32(controlKey) }
        return carbon
    }
}
