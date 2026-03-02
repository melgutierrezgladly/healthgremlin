import SwiftUI

// MARK: - SpeechBubbleView
// The speech bubble that appears next to the gremlin character
// containing the reminder message and action buttons.
//
// Layout:
// ┌────────────────────────────┐
// │  💧 Water Reminder         │
// │                            │
// │  "Might I suggest          │
// │   hydration? Your cells    │
// │   have been remarkably     │
// │   patient."                │
// │                            │
// │  [I did the thing ✅]      │
// │  [Delay ⏳]                │
// └────────────────────────────┘
//        ◄── little tail pointing to character

struct SpeechBubbleView: View {
    let message: String
    let category: String
    let tier: EscalationTier
    let onAcknowledge: () -> Void
    let onDelay: () -> Void
    // Demo mode: optional callback to cycle to the next tier
    var onNextTier: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // --- Header: category emoji + label ---
            HStack {
                Text(category)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(tier.accentColor)

                Spacer()

                // Tier indicator (subtle)
                Text(tier.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(tier.accentColor.opacity(0.15))
                    .cornerRadius(4)
            }

            // --- Message text ---
            ScrollView(.vertical, showsIndicators: false) {
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxHeight: 100)

            // --- Action buttons ---
            if let onNextTier = onNextTier {
                // DEMO MODE buttons
                HStack(spacing: 8) {
                    if tier != .unhingedGremlin {
                        // "Next Tier" — cycle to the next escalation level
                        Button(action: onNextTier) {
                            HStack(spacing: 4) {
                                Text("Next Tier")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("▶")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }

                    // "Exit Demo" — always available
                    Button(action: onAcknowledge) {
                        HStack(spacing: 4) {
                            Text("Exit Demo")
                                .font(.system(size: 11, weight: .semibold))
                            Text("✕")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.secondary.opacity(0.15))
                        .foregroundColor(.secondary)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // NORMAL buttons
                HStack(spacing: 8) {
                    // "I did the thing" button — acknowledges the reminder
                    Button(action: onAcknowledge) {
                        HStack(spacing: 4) {
                            Text("I did the thing")
                                .font(.system(size: 11, weight: .semibold))
                            Text("✅")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)

                    // "Delay" button — snoozes but counts as ignored (escalates!)
                    Button(action: onDelay) {
                        HStack(spacing: 4) {
                            Text("Delay")
                                .font(.system(size: 11, weight: .medium))
                            Text("⏳")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.secondary.opacity(0.15))
                        .foregroundColor(.secondary)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)  // Frosted glass effect — very macOS
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(tier.accentColor.opacity(0.3), lineWidth: 1)
        )
    }
}
