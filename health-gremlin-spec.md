# Health Gremlin — Product Spec v1.0

## Overview

**Health Gremlin** is a native macOS menu bar app that delivers periodic health reminders (stand, sit, water, walk, dance, calisthenics) via a small floating character overlay — think Clippy meets JARVIS. The character starts as a polished, dry-witted AI butler and escalates to chaotic gremlin energy if reminders are ignored.

**Tech stack:** Swift/SwiftUI, macOS native  
**Target:** macOS 14+ (Sonoma)  
**Distribution:** Local build via Claude Code (not App Store)

---

## Core Personality System

### The Escalation Arc

The character has **3 tiers** of personality based on whether the user acknowledges reminders:

| Tier | Trigger | Tone | Example |
|------|---------|------|---------|
| **Tier 1: JARVIS** | Default state | Calm, dry British wit. Polite but slightly sardonic. | "Might I suggest you hydrate, ma'am? Your cells are filing a formal complaint." |
| **Tier 2: Concerned JARVIS** | 1 ignored reminder | Slightly more insistent, passive-aggressive. Still composed. | "I don't wish to alarm you, but your spine has begun drafting a resignation letter." |
| **Tier 3: Unhinged Gremlin** | 2+ ignored reminders | Full chaos. Dramatic. Absurd. The mask comes off. | "STAND UP. STAND UP RIGHT NOW. I WILL WIGGLE. YOU DO NOT WANT ME TO WIGGLE." |

**Reset behavior:** Successfully completing a reminder (hitting "I did the thing") resets the escalation tier back to Tier 1 for that reminder type.

---

## Reminder Types & Smart Timing

### Reminder Categories

| Category | Default Interval | Variation Range | Examples |
|----------|-----------------|-----------------|----------|
| **Stand/Sit** | Every 45 min | 35–55 min | "Time to change altitude." |
| **Water** | Every 30 min | 20–40 min | "Your organs would like a word. The word is 'water'." |
| **Walk** | Every 90 min | 75–120 min | "A brief constitutional is in order." |
| **Dance** | Every 2 hours | 90–150 min | "I believe this is what the humans call 'a vibe check'." |
| **Calisthenics** | Every 2 hours | 90–150 min | Specific mini-exercises (see below) |

### Calisthenics Exercise Pool

The app should randomly select from a pool of quick exercises. Each prompt specifies the exercise and rep count:

- 5–10 pushups
- 10–15 squats
- 10–15 lunges (each leg)
- 20–30 second plank
- 10 burpees (Tier 3 only — as punishment)
- 15–20 calf raises
- 10 tricep dips (using chair)
- 20 jumping jacks

### Smart Timing Logic

- Intervals should have **randomized jitter** within the variation range (not perfectly predictable)
- If a user just completed a "stand" reminder, don't immediately fire a "walk" reminder — enforce a **minimum 10-minute gap** between any two reminders
- After the app is first opened or resumed from pause, start the first reminder after a **5-minute grace period**
- Reminder timers **pause** if the user manually triggers a keyboard shortcut (self-reported activity resets related timers)

---

## User Interface

### Menu Bar Icon
- Small icon in the macOS menu bar (a little gremlin face or health icon)
- Click to open a dropdown with:
  - **Pause/Resume** all reminders (with duration options: 15 min, 30 min, 1 hour, until resumed)
  - **Settings** (adjust intervals per category)
  - **Quit**

### The Floating Character (The Star of the Show)

When a reminder fires, a **small floating character** appears on screen:

- **Size:** Approximately 120–160px, similar to old Clippy
- **Position:** Bottom-right corner of the screen by default, but draggable
- **Appearance:**
  - Tier 1: Clean, composed icon/avatar — could be a simple illustrated butler or robot face
  - Tier 2: Same character but visually slightly agitated (subtle animation change)
  - Tier 3: Full gremlin mode — could shake, bounce, grow slightly, change color/expression
- **Speech bubble:** The reminder text appears in a speech bubble next to the character
- **Visual only:** No sounds or audio. Ever. This is a silent gremlin.

### Interaction Buttons

Each reminder popup has two buttons:

| Button | Action |
|--------|--------|
| **"I did the thing" ✅** | Dismisses the reminder, resets escalation tier to 1, resets that category's timer |
| **"Delay" ⏳** | Snoozes the reminder for 5 minutes, counts as an ignored reminder for escalation purposes |

**Important:** Hitting "Delay" advances the escalation tier. So: first appearance = Tier 1 → Delay → reappears in 5 min at Tier 2 → Delay again → reappears in 5 min at Tier 3 (full chaos).

### Auto-Dismiss

If the user neither delays nor acknowledges within **3 minutes**, the popup auto-dismisses and counts as ignored (escalation advances). The reminder re-fires in 5 minutes at the next tier.

---

## Keyboard Shortcuts

These allow the user to **self-report** activities proactively (e.g., they got up to pee and want credit):

| Shortcut | Action |
|----------|--------|
| `⌘ + Shift + S` | "I just stood up" — resets stand/sit timer |
| `⌘ + Shift + D` | "I just sat down" — resets stand/sit timer |
| `⌘ + Shift + W` | "I just drank water" — resets water timer |
| `⌘ + Shift + K` | "I just walked/moved" — resets walk timer |
| `⌘ + Shift + P` | Pause/resume all reminders |

When a shortcut is triggered, the character should briefly appear with an approving quip:
- Tier 1 response: "Noted. Well done, ma'am." 
- Or: "Excellent initiative. I'll update your file."
- Or: "Self-sufficient. I respect that."

The quip disappears after 2 seconds.

---

## Reminder Copy Bank

The app should include a **bank of pre-written messages** for each category at each tier. Messages should be randomly selected (no immediate repeats). Here's a starter set — the spec should ship with at least **5–8 messages per category per tier**:

### Water Reminders

**Tier 1 (JARVIS):**
- "Might I suggest hydration? Your cells have been remarkably patient."
- "A glass of water, perhaps. I hear it's what keeps the organs from unionizing."
- "Hydration check. Your body is 60% water and currently filing a grievance about the other 40%."

**Tier 2 (Concerned JARVIS):**
- "I've now asked twice about the water situation. This is becoming a pattern."
- "Your kidneys have asked me to intervene. I don't enjoy being the middleman."

**Tier 3 (Unhinged Gremlin):**
- "DRINK WATER OR I WILL HAUNT YOUR DESKTOP FOREVER. I LIVE HERE NOW."
- "I am BEGGING you. The water is RIGHT THERE. I can see it. I have EYES now."
- "This is a hostage situation. The hostage is your hydration. I am the negotiator. DRINK."

*(The full app should have 5–8 per tier per category. Claude Code should generate the complete set during build, maintaining the voice progression.)*

---

## Configuration / Settings

Accessible from the menu bar dropdown. Simple preferences panel:

- **Per-category interval sliders** (with min/max range per category)
- **Pause duration** quick-select
- **Launch at login** toggle
- **Character position** (bottom-right, bottom-left, top-right, top-left)

No tracking, no analytics, no data collection. This app is between the user and the gremlin. 🤫

---

## Technical Notes for Claude Code

### Architecture Guidance
- **SwiftUI** for the menu bar app and settings panel
- **NSWindow** (or NSPanel) for the floating character overlay — needs to float above other windows, be non-activating (doesn't steal focus), and be on all Spaces/desktops
- **Timer management:** Use a central timer coordinator that manages all category timers, enforces minimum gaps, and handles jitter
- **Message bank:** Store as a structured JSON or Swift dictionary, keyed by category and tier
- **Keyboard shortcuts:** Register global hotkeys using `CGEvent` tap or similar macOS API
- **No external dependencies** if possible — keep it pure Swift/SwiftUI

### File Structure Suggestion
```
HealthGremlin/
├── HealthGremlinApp.swift          # App entry point, menu bar setup
├── Models/
│   ├── ReminderCategory.swift      # Enum for reminder types
│   ├── EscalationTier.swift        # Tier logic
│   └── TimerCoordinator.swift      # Smart timing engine
├── Views/
│   ├── FloatingCharacterView.swift # The Clippy-style overlay
│   ├── SpeechBubbleView.swift      # Message display
│   ├── SettingsView.swift          # Preferences panel
│   └── MenuBarView.swift           # Dropdown menu
├── Resources/
│   └── MessageBank.json            # All reminder messages
└── Utilities/
    ├── HotkeyManager.swift         # Global keyboard shortcuts
    └── WindowManager.swift         # Overlay window management
```

### Build & Run
This should be buildable with `swift build` or via Xcode project generation. Claude Code should set up the project with proper `Package.swift` or `.xcodeproj`.

---

## What This App Is NOT

- ❌ Not a Pomodoro timer
- ❌ Not a fitness tracker
- ❌ Not collecting any data
- ❌ Not making sounds (SILENT GREMLIN)
- ❌ Not a to-do list or productivity tool
- ❌ Not taking itself too seriously

---

## Success Criteria

The app is successful if:
1. Mel actually drinks more water
2. Mel's spine files fewer complaints
3. The Tier 3 messages make Mel laugh out loud at least once a week
4. It runs quietly in the background without being annoying (until it's *supposed* to be annoying)

---

*Spec written: February 5, 2026*  
*Version: 1.0*  
*Status: Ready for Claude Code*
