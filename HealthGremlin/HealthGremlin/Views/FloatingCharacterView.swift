import SwiftUI

// MARK: - FloatingCharacterView
// The gremlin character itself — a visual representation that changes
// based on the current escalation tier.
//
// Phase 2: Simple placeholder design (circle with face).
// Phase 6: Will be replaced with proper character art/animations.
//
// Tier 1 (JARVIS): Calm, composed — neutral gray, gentle expression
// Tier 2 (Concerned): Slightly agitated — orange tint, eyebrows furrowed
// Tier 3 (Gremlin): Full chaos — red, shaking, maybe bigger

struct FloatingCharacterView: View {
    let tier: EscalationTier

    // Shake animation state for Tier 3
    @State private var isShaking = false
    // Bounce animation for Tier 3
    @State private var bounceOffset: CGFloat = 0

    // Character size grows slightly with escalation
    private var characterSize: CGFloat {
        switch tier {
        case .jarvis: return 80
        case .concernedJarvis: return 85
        case .unhingedGremlin: return 95    // Bigger = more threatening
        }
    }

    var body: some View {
        ZStack {
            // --- Body: round circle ---
            Circle()
                .fill(tier.characterColor.gradient)
                .frame(width: characterSize, height: characterSize)
                .shadow(color: tier.accentColor.opacity(0.5), radius: tier == .unhingedGremlin ? 10 : 4)

            // --- Face ---
            VStack(spacing: 4) {
                // Eyes
                HStack(spacing: tier == .unhingedGremlin ? 20 : 16) {
                    EyeView(tier: tier, isLeft: true)
                    EyeView(tier: tier, isLeft: false)
                }

                // Mouth
                MouthView(tier: tier)
            }
            .offset(y: 2)

            // --- Ears (pointy triangles on the sides) ---
            // Left ear
            EarView(tier: tier)
                .offset(x: -(characterSize / 2 + 8), y: -5)

            // Right ear
            EarView(tier: tier)
                .scaleEffect(x: -1, y: 1)  // Mirror horizontally
                .offset(x: characterSize / 2 + 8, y: -5)
        }
        // Tier 3: shake animation — the gremlin is LOSING IT
        .rotationEffect(.degrees(isShaking ? 3 : -3))
        .offset(y: bounceOffset)
        .onAppear {
            if tier == .unhingedGremlin {
                // Rapid shaking
                withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
                    isShaking.toggle()
                }
                // Bouncing
                withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                    bounceOffset = -8
                }
            }
        }
    }
}

// MARK: - Eye component
struct EyeView: View {
    let tier: EscalationTier
    let isLeft: Bool

    var body: some View {
        ZStack {
            // White of the eye
            Ellipse()
                .fill(.white)
                .frame(
                    width: tier == .unhingedGremlin ? 18 : 14,
                    height: tier == .unhingedGremlin ? 18 : 14
                )

            // Pupil
            Circle()
                .fill(.black)
                .frame(
                    width: tier == .unhingedGremlin ? 10 : 7,
                    height: tier == .unhingedGremlin ? 10 : 7
                )

            // Tier 2+: angry eyebrow line
            if tier != .jarvis {
                Rectangle()
                    .fill(.black)
                    .frame(width: 16, height: 2.5)
                    .rotationEffect(.degrees(isLeft ? 15 : -15))
                    .offset(y: -12)
            }
        }
    }
}

// MARK: - Mouth component
struct MouthView: View {
    let tier: EscalationTier

    var body: some View {
        ZStack {
            switch tier {
            case .jarvis:
                // Calm, slight smile — a simple line
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white)
                    .frame(width: 24, height: 3)

            case .concernedJarvis:
                // Grimace — wavy/tense mouth
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white)
                    .frame(width: 28, height: 3)

            case .unhingedGremlin:
                // Wide open grin with fangs!
                ZStack {
                    // Open mouth
                    Capsule()
                        .fill(.white)
                        .frame(width: 34, height: 12)

                    // Fangs (two little triangles)
                    HStack(spacing: 16) {
                        FangView()
                        FangView()
                    }
                    .offset(y: 2)
                }
            }
        }
    }
}

// MARK: - Fang component (for Tier 3)
struct FangView: View {
    var body: some View {
        Triangle()
            .fill(.white)
            .frame(width: 6, height: 8)
    }
}

// MARK: - Ear component (pointy gremlin ears)
struct EarView: View {
    let tier: EscalationTier

    var body: some View {
        Triangle()
            .fill(tier.characterColor.gradient)
            .frame(width: 20, height: 16)
            .rotationEffect(.degrees(-90))
    }
}

// MARK: - Triangle shape (used for ears and fangs)
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
