# 🐸 Health Gremlin

A native macOS menu bar app that nags you to take care of yourself — with escalating sass.

Health Gremlin delivers periodic reminders to drink water, stand up, walk, dance, and exercise. Ignore it, and the gremlin gets *increasingly unhinged*.

![macOS](https://img.shields.io/badge/macOS-14%2B%20Sonoma-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)
![Network](https://img.shields.io/badge/network-none-brightgreen)
![Tracking](https://img.shields.io/badge/tracking-zero-brightgreen)

---

## How It Works

A small gremlin lives in your menu bar. At randomized intervals, it pops up as a floating overlay with a health reminder and two buttons:

- **"I did the thing" ✅** — Dismisses the reminder. The gremlin calms down.
- **"Delay" ⏳** — Snoozes for 5 minutes. The gremlin gets angrier.

If you ignore it entirely, it escalates on its own.

### The Escalation Tiers

| Tier | Vibe | Example |
|------|------|---------|
| 🎩 Jarvis | Polite British butler | *"Might I suggest hydration? Your cells have been remarkably patient."* |
| 👵 Nanny | Passive-aggressive caretaker | *"Oh, so we're just going to sit here like a houseplant with anxiety?"* |
| 🔥 Drill Sergeant | Unhinged chaos gremlin | *"YOUR SPINE IS FILING A CLASS ACTION LAWSUIT."* |

### Reminder Categories

| Category | Default Interval |
|----------|-----------------|
| 💧 Water | 30 min |
| 🧍 Stand/Sit | 45 min |
| 🚶 Walk | 90 min |
| 💃 Dance | 2 hours |
| 💪 Calisthenics | 2 hours |

All intervals have ±25% randomized jitter so reminders don't feel robotic, and there's always at least 10 minutes between any two reminders.

---

## Installation

### Prerequisites

- **macOS 14 (Sonoma) or later**
- **Xcode Command Line Tools** (for the Swift toolchain)
  ```bash
  xcode-select --install
  ```

### Build & Run

```bash
# Clone the repo
git clone https://github.com/melgutierrezgladly/healthgremlin.git
cd healthgremlin/HealthGremlin

# Build and launch
bash build-and-run.sh
```

Look for the gremlin icon (🐸) in your menu bar.

### Optional: Move to Applications

```bash
cp -R .build/HealthGremlin.app /Applications/
open /Applications/HealthGremlin.app
```

### Launch at Login

Menu bar icon → ⚙ Settings → check **"Launch at login"**

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘⇧H | Dismiss active reminder |
| ⌘⇧W | Self-report: "I drank water" |
| ⌘⇧S | Self-report: "I stood/sat" |

Self-reporting resets the timer for that category without a popup ever appearing. All shortcuts are customizable in Settings.

---

## Demo Mode

Want to see all three escalation tiers without waiting?

Menu bar icon → **🎬 Demo Mode** → pick a category. The gremlin cycles through Jarvis → Nanny → Drill Sergeant with a "Next Tier ▶" button.

---

## Settings

Click the menu bar icon → **⚙ Settings** to customize:

- Reminder intervals per category
- Gremlin screen position (corner of screen)
- Keyboard shortcuts
- Debug mode (30x faster timers for testing)
- Launch at login

---

## Tech Stack

- **Swift / SwiftUI** — 100% native, no Electron, no web views
- **Swift Package Manager** — no Xcode project needed
- **AppKit (NSPanel)** — floating overlay visible on all Spaces
- **Carbon (RegisterEventHotKey)** — global keyboard shortcuts
- **Zero external dependencies** — only Apple frameworks

---

## Privacy

- **No network calls.** The app never connects to the internet.
- **No tracking or analytics.** Zero telemetry.
- **No data collection.** Your settings are stored locally in UserDefaults.
- **No microphone, camera, contacts, or file access.**

What happens between you and the gremlin stays between you and the gremlin.

---

## Project Structure

```
HealthGremlin/
├── Package.swift
├── build-and-run.sh
└── HealthGremlin/
    ├── HealthGremlinApp.swift          # App entry point
    ├── Info.plist
    ├── Models/
    │   ├── TimerCoordinator.swift      # Timer logic & escalation
    │   ├── MessageBank.swift           # Message loading
    │   ├── ReminderCategory.swift      # Category definitions
    │   ├── EscalationTier.swift        # Tier definitions
    │   └── HotkeyConfig.swift          # Shortcut config
    ├── Views/
    │   ├── MenuBarView.swift           # Menu bar dropdown
    │   ├── ReminderOverlayView.swift   # Floating overlay
    │   ├── FloatingCharacterView.swift # Gremlin character
    │   ├── SpeechBubbleView.swift      # Message bubble + buttons
    │   ├── SettingsView.swift          # Preferences panel
    │   └── HotkeyRecorderView.swift    # Shortcut recorder
    ├── Utilities/
    │   ├── WindowManager.swift         # NSPanel management
    │   └── HotkeyManager.swift         # Carbon hotkey registration
    └── Resources/
        └── MessageBank.json            # All gremlin messages
```

---

## Built With

Built with [Claude Code](https://claude.ai/code) — Anthropic's AI coding agent.
