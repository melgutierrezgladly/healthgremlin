import Foundation

// MARK: - ReminderCategory
// Defines the types of health reminders the gremlin can deliver.
// Each category has its own timer, escalation state, and message bank.
//
// Interval values come from UserDefaults (set in Settings) if available,
// otherwise fall back to hardcoded defaults. The jitter range is
// calculated as ±25% around the user's chosen interval.

enum ReminderCategory: String, CaseIterable, Identifiable {
    case standSit = "Stand/Sit"
    case water = "Water"
    case walk = "Walk"
    case dance = "Dance"
    case calisthenics = "Calisthenics"

    var id: String { rawValue }

    /// The UserDefaults key for this category's interval setting (in minutes)
    private var userDefaultsKey: String {
        switch self {
        case .standSit:     return "interval_standSit"
        case .water:        return "interval_water"
        case .walk:         return "interval_walk"
        case .dance:        return "interval_dance"
        case .calisthenics: return "interval_calisthenics"
        }
    }

    /// The hardcoded default interval in minutes (used if no setting saved)
    private var defaultMinutes: Double {
        switch self {
        case .standSit:     return 45
        case .water:        return 30
        case .walk:         return 90
        case .dance:        return 120
        case .calisthenics: return 120
        }
    }

    // Default interval in seconds — reads from UserDefaults, falls back to hardcoded
    var defaultInterval: TimeInterval {
        let stored = UserDefaults.standard.double(forKey: userDefaultsKey)
        let minutes = stored > 0 ? stored : defaultMinutes
        return minutes * 60
    }

    // Minimum interval in seconds (lower bound of jitter range)
    // Calculated as 75% of the user's chosen interval
    var minimumInterval: TimeInterval {
        return defaultInterval * 0.75
    }

    // Maximum interval in seconds (upper bound of jitter range)
    // Calculated as 125% of the user's chosen interval
    var maximumInterval: TimeInterval {
        return defaultInterval * 1.25
    }

    /// Whether this category is disabled when coworking mode is active
    var isDisabledInCoworkingMode: Bool {
        switch self {
        case .dance, .calisthenics: return true
        case .water, .standSit, .walk: return false
        }
    }

    /// Whether this category is currently active (respects coworking mode)
    var isCurrentlyActive: Bool {
        if isDisabledInCoworkingMode {
            return !UserDefaults.standard.bool(forKey: "coworkingMode")
        }
        return true
    }

    // Emoji for quick visual identification in the UI
    var emoji: String {
        switch self {
        case .standSit:     return "🧍"
        case .water:        return "💧"
        case .walk:         return "🚶"
        case .dance:        return "💃"
        case .calisthenics: return "💪"
        }
    }
}
