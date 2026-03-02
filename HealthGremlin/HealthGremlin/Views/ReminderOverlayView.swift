import SwiftUI

// MARK: - ReminderOverlayView
// The complete floating overlay that combines the gremlin character
// and the speech bubble into one view. This is what gets hosted
// inside the NSPanel managed by WindowManager.
//
// Layout (bottom-right of screen):
// ┌──────────────────────────────────────┐
// │  ┌─────────────────────┐             │
// │  │   Speech bubble     │   🐸        │
// │  │   with message      │  (gremlin)  │
// │  │   and buttons       │             │
// │  └─────────────────────┘             │
// └──────────────────────────────────────┘

struct ReminderOverlayView: View {
    // ObservedObject so the view updates when WindowManager changes
    @ObservedObject var windowManager: WindowManager

    // Entrance animation state
    @State private var hasAppeared = false

    // Compute the current tier from the int stored in WindowManager
    private var tier: EscalationTier {
        EscalationTier(rawValue: windowManager.currentTier) ?? .jarvis
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // --- Speech bubble (left side) ---
            SpeechBubbleView(
                message: windowManager.currentMessage,
                category: windowManager.currentCategory,
                tier: tier,
                onAcknowledge: {
                    windowManager.onAcknowledge?()
                    windowManager.dismissReminder()
                },
                onDelay: {
                    windowManager.onDelay?()
                    windowManager.dismissReminder()
                },
                onNextTier: windowManager.onNextTier
            )
            .frame(maxWidth: 240)

            // --- Gremlin character (right side) ---
            FloatingCharacterView(tier: tier)
        }
        .padding(12)
        // Transparent background — the speech bubble has its own frosted glass
        .background(Color.clear)
        // Entrance animation: slide up + fade in
        .offset(y: hasAppeared ? 0 : 30)
        .opacity(hasAppeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                hasAppeared = true
            }
        }
    }
}
