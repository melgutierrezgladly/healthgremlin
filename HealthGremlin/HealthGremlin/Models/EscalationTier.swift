import SwiftUI

// MARK: - EscalationTier
// Represents the gremlin's current mood/escalation level.
//
// The personality escalates when reminders are ignored:
// Tier 1 (JARVIS) → Tier 2 (Concerned JARVIS) → Tier 3 (Unhinged Gremlin)
//
// Hitting "I did the thing" resets back to Tier 1.
// Hitting "Delay" or ignoring (auto-dismiss) advances to the next tier.

enum EscalationTier: Int, CaseIterable {
    case jarvis = 1          // Calm, dry British butler
    case concernedJarvis = 2 // Passive-aggressive, losing patience
    case unhingedGremlin = 3 // Full chaos mode

    // Display name for the tier (used in UI/debugging)
    var name: String {
        switch self {
        case .jarvis: return "JARVIS"
        case .concernedJarvis: return "Concerned JARVIS"
        case .unhingedGremlin: return "UNHINGED GREMLIN"
        }
    }

    // The color associated with each tier — visual escalation cue
    var accentColor: Color {
        switch self {
        case .jarvis: return .blue             // Calm blue
        case .concernedJarvis: return .orange   // Warning orange
        case .unhingedGremlin: return .red      // Danger red!
        }
    }

    // Background tint for the character at each tier
    var characterColor: Color {
        switch self {
        case .jarvis: return .gray              // Composed, neutral
        case .concernedJarvis: return .orange    // Getting agitated
        case .unhingedGremlin: return .red       // FULL GREMLIN
        }
    }

    // Advance to the next tier (caps at Tier 3 — it doesn't get worse than gremlin)
    var next: EscalationTier {
        switch self {
        case .jarvis: return .concernedJarvis
        case .concernedJarvis: return .unhingedGremlin
        case .unhingedGremlin: return .unhingedGremlin  // Already max chaos
        }
    }
}
