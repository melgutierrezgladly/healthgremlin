# Health Gremlin — Complete Reference Guide

> **For Claude Chat, Claude Code, and Gladiators who want their own desktop gremlin.**
>
> This document is the single source of truth for Health Gremlin — what it is, how it works, how to install it, how to troubleshoot it, and how to help others get it running.

---

## Table of Contents

1. [What Is Health Gremlin?](#what-is-health-gremlin)
2. [How It Works](#how-it-works)
3. [Installation Guide (For Other Gladiators)](#installation-guide)
4. [Configuration & Settings](#configuration--settings)
5. [Keyboard Shortcuts](#keyboard-shortcuts)
6. [The Personality System](#the-personality-system)
7. [Demo Mode](#demo-mode)
8. [Troubleshooting Guide](#troubleshooting-guide)
9. [Claude Code Skill Reference](#claude-code-skill-reference)
10. [Architecture Overview (For Claude Code)](#architecture-overview)
11. [All Source Files](#all-source-files)

---

## What Is Health Gremlin?

Health Gremlin is a native macOS menu bar app that reminds you to take care of your body while you work. It delivers periodic health reminders — stand up, drink water, take a walk, dance, do some calisthenics — through a small floating character overlay (think Clippy meets JARVIS).

**The twist:** If you ignore the reminders, the character's personality escalates from a polished British butler to a full-on unhinged chaos gremlin.

### Key Facts
- **Platform:** macOS 14+ (Sonoma) only
- **Language:** Swift/SwiftUI (100% native, no Electron, no web views)
- **Distribution:** Built locally via Claude Code (not on the App Store)
- **Privacy:** Zero tracking, zero analytics, zero data collection. What happens between you and the gremlin stays between you and the gremlin.
- **Sound:** Completely silent. Always. This is a visual-only gremlin.
- **Dependencies:** None. Pure Apple frameworks only.

### What It Is NOT
- Not a Pomodoro timer
- Not a fitness tracker
- Not collecting any data
- Not making sounds (SILENT GREMLIN)
- Not a to-do list or productivity tool
- Not taking itself too seriously

---

## How It Works

### The Basics

1. **Health Gremlin lives in your menu bar** — a small gremlin icon sits next to your clock, Wi-Fi, etc.
2. **At randomized intervals**, a floating character pops up in the corner of your screen with a reminder (e.g., "Might I suggest hydration? Your cells have been remarkably patient.")
3. **Two buttons appear:**
   - **"I did the thing" ✅** — Dismisses the reminder, resets the timer, resets the gremlin to its calm personality.
   - **"Delay" ⏳** — Snoozes for 5 minutes, but the gremlin gets angrier next time.
4. **If you ignore it entirely** (no button press for 3 minutes), it counts as a "Delay" — the gremlin escalates and comes back in 5 minutes.

### Reminder Categories

| Category | Default Interval | What It Reminds You |
|----------|-----------------|---------------------|
| 💧 Water | Every 30 min | Drink water |
| 🧍 Stand/Sit | Every 45 min | Change your position |
| 🚶 Walk | Every 90 min | Get up and move |
| 💃 Dance | Every 2 hours | Dance break! |
| 💪 Calisthenics | Every 2 hours | Quick exercise (pushups, squats, plank, etc.) |

### Smart Timing
- **Randomized jitter:** Reminders aren't robotically predictable. Each one fires within ±25% of the base interval (so a 30-min water reminder actually fires somewhere between ~22 and ~38 minutes).
- **Minimum gap:** At least 10 minutes between any two reminders, so you're never bombarded.
- **Grace period:** 5 minutes of peace after the app launches before the first reminder.
- **Self-reporting:** Press a keyboard shortcut to tell the gremlin you already did the thing, and it resets that timer without ever popping up.

---

## Installation Guide

### Prerequisites

- **macOS 14 (Sonoma) or later** — the app uses APIs that only exist in macOS 14+
- **Swift toolchain** — comes with Xcode or Xcode Command Line Tools
- **Claude Code** — for building the project (or the terminal, if you're comfortable with `swift build`)

### Option A: Install with Claude Code (Recommended)

1. **Clone or copy the project** to your Mac:
   ```bash
   # If shared via git:
   git clone <repo-url> ~/Claude-playground/healthgremlin

   # Or if shared as a zip/folder, just put it somewhere convenient:
   # e.g., ~/Claude-playground/healthgremlin/
   ```

2. **Open Claude Code** and navigate to the project:
   ```bash
   cd ~/Claude-playground/healthgremlin/HealthGremlin
   ```

3. **Build and launch:**
   ```bash
   bash build-and-run.sh
   ```

4. **Look for the gremlin icon** in your menu bar (top-right of your screen, near the clock). It's a small gremlin face.

5. **Grant Accessibility permission** (required for global keyboard shortcuts):
   - Go to **System Settings → Privacy & Security → Accessibility**
   - Click the **+** button and add `HealthGremlin.app` (located at `~/Claude-playground/healthgremlin/HealthGremlin/.build/HealthGremlin.app`)
   - Toggle it **ON**

6. **You're done!** The gremlin will start reminding you after a 5-minute grace period.

### Option B: Manual Build (Terminal Only)

```bash
cd ~/Claude-playground/healthgremlin/HealthGremlin

# Build the Swift package
swift build

# The build script creates the .app bundle and launches it:
bash build-and-run.sh
```

### Moving the App to Applications (Optional)

If you want to keep it more permanently:
```bash
cp -R ~/Claude-playground/healthgremlin/HealthGremlin/.build/HealthGremlin.app /Applications/
open /Applications/HealthGremlin.app
```

### Launch at Login

Once the app is running, click the gremlin icon → Settings → check "Launch at login". This uses macOS's built-in SMAppService to register the app as a login item.

---

## Configuration & Settings

Click the gremlin menu bar icon → **⚙ Settings...** to open the preferences panel.

### Reminder Intervals
Adjust how often each type of reminder fires (all values in minutes):

| Category | Range | Default |
|----------|-------|---------|
| 💧 Water | 10–60 min | 30 min |
| 🧍 Stand/Sit | 15–90 min | 45 min |
| 🚶 Walk | 30–180 min | 90 min |
| 💃 Dance | 30–240 min | 120 min |
| 💪 Calisthenics | 30–240 min | 120 min |

Changes take effect when you click **"Apply & Close"** — all active timers restart with the new intervals.

### Character Position
Choose which corner of the screen the gremlin appears in:
- ↘ Bottom Right (default)
- ↙ Bottom Left
- ↗ Top Right
- ↖ Top Left

### General
- **Launch at login** — Start Health Gremlin automatically when you log in
- **Debug mode** — 30x faster timers for testing (OFF by default)

### Keyboard Shortcuts
All shortcuts are customizable. Click a shortcut field, then press your desired key combo. Requirements:
- Must include at least one modifier key (⌘, ⌃, or ⌥)
- Shift alone doesn't count as a modifier
- Some macOS system shortcuts (like Ctrl+1 for Spaces) can't be overridden

---

## Keyboard Shortcuts

### Default Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘⇧S | "I just stood up" — resets stand/sit timer |
| ⌘⇧D | "I just sat down" — resets stand/sit timer |
| ⌘⇧W | "I drank water" — resets water timer |
| ⌘⇧K | "I walked/moved" — resets walk timer |
| ⌘⇧P | Pause/resume all reminders |

When you self-report via keyboard shortcut, the gremlin briefly appears with an approving quip like "Noted. Well done, ma'am." or "Excellent initiative. I'll update your file." — then disappears after 2 seconds.

### Pause/Resume

From the menu bar dropdown, you can pause reminders for:
- 15 minutes
- 30 minutes
- 1 hour
- Until manually resumed

The menu bar status shows whether reminders are active (✅) or paused (⏸).

---

## The Personality System

### Three Tiers of Escalation

Each reminder category has its own escalation state. The more you ignore a specific category, the more unhinged the gremlin gets for that category.

#### Tier 1: JARVIS (Default)
- **Personality:** Calm British butler. Dry wit. Polite but slightly sardonic.
- **Visual:** Gray body, blue accent, calm expression
- **Example:** "Might I suggest hydration? Your cells have been remarkably patient."

#### Tier 2: Concerned JARVIS
- **Personality:** Losing patience. Passive-aggressive. Still composed but clearly annoyed.
- **Visual:** Orange-tinted body, angry eyebrows, wider grimace
- **Example:** "I've now asked twice about the water situation. This is becoming a pattern."

#### Tier 3: Unhinged Gremlin
- **Personality:** Full chaos. ALL CAPS. Dramatic. Absurd. The mask comes off.
- **Visual:** Red body, larger size, shaking animation, bouncing, fangs
- **Example:** "DRINK WATER OR I WILL HAUNT YOUR DESKTOP FOREVER. I LIVE HERE NOW."

### Escalation Rules

| Action | Effect |
|--------|--------|
| Click "I did the thing" ✅ | Reset to Tier 1, restart timer |
| Click "Delay" ⏳ | Advance to next tier, come back in 5 min |
| Ignore for 3 minutes | Same as Delay (advance tier, come back in 5 min) |
| Self-report via hotkey | Reset to Tier 1, restart timer |

**Tier 3 is the maximum** — it can't escalate further, but it stays at peak chaos until you acknowledge it.

### Calisthenics Exercises

The calisthenics category randomly selects from a pool of quick exercises:
- 5–10 pushups
- 10–15 squats
- 10–15 lunges (each leg)
- 20–30 second plank
- 15–20 calf raises
- 10 tricep dips (using your chair)
- 20 jumping jacks
- **Tier 3 only:** 10 BURPEES (as punishment)

---

## Demo Mode

Demo Mode lets you showcase all 3 escalation tiers using the real floating overlay with live animations — perfect for recording a demo video or showing someone how the app works.

### How to Use

1. **Click the gremlin icon** in the menu bar
2. **Hover over "🎬 Demo Mode"** and pick a reminder category (Water, Stand/Sit, Walk, Dance, or Calisthenics)
3. **Tier 1 (JARVIS)** appears with a real message from the message bank
   - Click **"Next Tier ▶"** to advance to Tier 2
   - Click **"Exit Demo ✕"** to stop the demo at any time
4. **Tier 2 (Concerned JARVIS)** shows the character with orange tint, angry eyebrows, and a passive-aggressive message
   - Click **"Next Tier ▶"** to advance to Tier 3
5. **Tier 3 (Unhinged Gremlin)** goes full chaos: red character, shaking/bouncing animations, ALL CAPS message
   - At Tier 3, only **"Exit Demo ✕"** remains (there's no Tier 4)
6. Clicking **"Exit Demo"** dismisses the overlay and resumes normal reminder operation

### What Happens During Demo Mode

- Normal reminder timers are **paused** so they don't interrupt the demo
- Auto-dismiss is **disabled** — the overlay stays until you interact with it
- Each tier shows a **different random message** from the message bank
- If reminders were paused before the demo started, they **stay paused** after exiting
- If reminders were active, they **resume automatically** after exiting

### Tips for Recording

- Use a category with distinctive messages (Water and Stand/Sit have great personality progression)
- The Tier 3 shaking/bouncing animation is the star — linger on it
- You can run the demo multiple times to get different messages each time
- Demo Mode is disabled while a real reminder is already showing

---

## Troubleshooting Guide

### The gremlin icon doesn't appear in the menu bar

**Cause:** The app needs to be packaged as a `.app` bundle for macOS to display the menu bar icon. A raw executable won't work.

**Fix:**
1. Make sure you're using `build-and-run.sh` (not just `swift build` alone):
   ```bash
   cd ~/Claude-playground/healthgremlin/HealthGremlin
   bash build-and-run.sh
   ```
2. If it still doesn't appear, check if the app is running:
   ```bash
   ps aux | grep HealthGremlin
   ```
3. Try killing any zombie processes and relaunching:
   ```bash
   pkill -f HealthGremlin
   bash build-and-run.sh
   ```

### Keyboard shortcuts don't work

**Cause 1: Accessibility permission not granted.**
- Go to **System Settings → Privacy & Security → Accessibility**
- Make sure `HealthGremlin.app` is listed AND toggled on
- If you rebuilt the app, you may need to remove and re-add it (macOS ties permissions to the specific binary)

**Cause 2: Key combo intercepted by macOS.**
- Shortcuts like **Ctrl+number** (1-9) are grabbed by macOS for Mission Control/Spaces switching
- These can't be used unless you disable the macOS shortcuts in **System Settings → Keyboard → Keyboard Shortcuts → Mission Control**
- Use combos with ⌘ (Command) instead, e.g., ⌘⇧S

**Cause 3: Another app is using the same shortcut.**
- Open Settings → Keyboard Shortcuts and change to a different combo
- Make sure you include at least one modifier (⌘, ⌃, or ⌥)

### The hotkey recorder field doesn't capture my key press

**Cause:** The Settings window must be the frontmost window and have keyboard focus.

**Fix:**
1. Click directly on the hotkey recorder field (it should show "Press keys..." with a blue border)
2. Make sure no other app has stolen focus
3. Press Escape to cancel and try again
4. If the window keeps losing focus, close and reopen Settings

**Technical note:** This was a known challenge during development. The app temporarily switches to "regular" activation policy while the Settings window is open so it can receive keyboard events. If this isn't working, quit the app, relaunch, and try again.

### Reminders aren't appearing

**Check 1:** Is the app paused? Click the menu bar icon — it should say "✅ Reminders Active", not "⏸ Reminders Paused".

**Check 2:** Are you still in the grace period? The app waits 5 minutes after launch before the first reminder. In debug mode, this is ~10 seconds.

**Check 3:** Is debug mode off? If debug mode got left on, reminders fire very frequently (every ~1 minute). If it's off but you haven't waited long enough, just be patient — the default water timer is 30 minutes.

**Check 4:** Are the intervals set correctly? Open Settings and check that interval sliders aren't set to very long values.

### Reminders appear but buttons don't work

**Fix:** This can happen if the overlay window lost its event connection. Quit and relaunch:
```bash
pkill -f HealthGremlin
bash build-and-run.sh
```

### The gremlin appears behind other windows

**Fix:** The gremlin should float above all windows. If it's appearing behind something:
1. It may be a full-screen app issue — try swiping to a regular desktop
2. Quit and relaunch the app
3. The floating panel is configured with `.floating` level and `.fullScreenAuxiliary` — it should appear above everything

### Build fails with Swift errors

**Error: "No such module 'SwiftUI'"**
- Make sure Xcode Command Line Tools are installed:
  ```bash
  xcode-select --install
  ```

**Error: "Package requires macOS 14"**
- You need macOS 14 (Sonoma) or later. Check your version in  → About This Mac.

**Error: "Cannot find type 'NSEvent' in scope"**
- This was fixed by adding `import AppKit` to HotkeyConfig.swift. Make sure all files have their correct imports.

**General build issues:**
```bash
# Clean build and retry:
cd ~/Claude-playground/healthgremlin/HealthGremlin
rm -rf .build
swift build
bash build-and-run.sh
```

### The app shows "Debug Mode (30x speed)" in the menu

**Fix:** Open Settings → General → uncheck "🧪 Debug mode (fast timers)" → click "Apply & Close"

### Settings changes don't take effect

**Fix:** Make sure you click **"Apply & Close"** — just changing the sliders doesn't save. The Apply button saves all settings to UserDefaults and restarts the timers.

### The app appears in the Dock when Settings is open

**This is expected.** The app temporarily switches to "regular" activation policy while the Settings window is open (required for the hotkey recorder to receive keyboard events). When you close Settings, the dock icon disappears and the app goes back to menu-bar-only mode.

### Launch at Login isn't working

**Fix:** macOS requires the app to be in a stable location. If you move the `.app` bundle after enabling Launch at Login, you'll need to:
1. Open Settings → uncheck "Launch at login" → Apply
2. Move the app to its final location (e.g., `/Applications/`)
3. Launch the app from its new location
4. Re-enable "Launch at login"

---

## Claude Code Skill Reference

Use this section when helping troubleshoot or modify Health Gremlin with Claude Code.

### Project Location
```
/Users/melissagutierrez/Claude-playground/healthgremlin/
```

### Quick Commands

```bash
# Build and launch
cd ~/Claude-playground/healthgremlin/HealthGremlin
bash build-and-run.sh

# Build only (no launch)
swift build

# Clean build
rm -rf .build && swift build

# Kill running instance
pkill -f HealthGremlin

# View logs (launch with stdout visible)
.build/arm64-apple-macosx/debug/HealthGremlin

# Check if running
ps aux | grep HealthGremlin
```

### Key Singletons
```swift
TimerCoordinator.shared          // Central reminder scheduler
WindowManager.shared              // Floating overlay manager
MessageBank.shared                // Message lookup
HotkeyManager.shared              // Global hotkey registration
HotkeyRecorderCoordinator.shared  // Hotkey capture (during settings)
```

### UserDefaults Keys
```
interval_water          (Double, minutes, default: 30)
interval_standSit       (Double, minutes, default: 45)
interval_walk           (Double, minutes, default: 90)
interval_dance          (Double, minutes, default: 120)
interval_calisthenics   (Double, minutes, default: 120)
characterPosition       (String: "bottomRight"|"bottomLeft"|"topRight"|"topLeft")
launchAtLogin           (Bool)
debugMode               (Bool)
hotkeyConfigs           (Data: JSON-encoded [String: HotkeyConfig])
```

### Common Modifications

**To add a new reminder category:**
1. Add a case to `ReminderCategory` enum in `Models/ReminderCategory.swift`
2. Add messages to `Resources/MessageBank.json` (all 3 tiers)
3. Add a UserDefaults key and interval slider in `SettingsView.swift`
4. TimerCoordinator will automatically schedule it (it iterates `ReminderCategory.allCases`)

**To add new messages:**
1. Edit `HealthGremlin/Resources/MessageBank.json`
2. Add messages to the appropriate category and tier arrays
3. Rebuild (`bash build-and-run.sh`)

**To change the character appearance:**
1. Edit `Views/FloatingCharacterView.swift`
2. Tier-based appearance is controlled by the `tier` parameter
3. Colors come from `EscalationTier.accentColor` and `.characterColor`

**To change timer behavior:**
1. Edit `Models/TimerCoordinator.swift`
2. Key constants: `minimumGapSeconds` (10 min), `gracePeriodSeconds` (5 min), `autoDismissSeconds` (3 min), `snoozeSeconds` (5 min)

### Debug Mode Timing

| Timer Type | Normal | Debug (30x) | Debug Interaction (3x) |
|-----------|--------|-------------|----------------------|
| Grace period | 5 min | ~10 sec | — |
| Water reminder | 30 min | ~1 min | — |
| Stand/Sit | 45 min | ~1.5 min | — |
| Walk | 90 min | ~3 min | — |
| Dance/Calisthenics | 120 min | ~4 min | — |
| Min gap between reminders | 10 min | ~20 sec | — |
| Auto-dismiss | 3 min | — | 60 sec |
| Snooze delay | 5 min | — | ~100 sec |

### Framework Imports by File

| Import | Used In | Purpose |
|--------|---------|---------|
| SwiftUI | Most views | UI framework |
| AppKit | WindowManager, MenuBarView, HotkeyConfig, HotkeyRecorderView | NSPanel, NSWindow, NSEvent, NSApplication |
| Foundation | All models | Timer, UserDefaults, Codable |
| Carbon | HotkeyManager, HotkeyConfig, HotkeyRecorderView | RegisterEventHotKey, key codes |
| Combine | TimerCoordinator | ObservableObject |
| ServiceManagement | SettingsView | SMAppService (launch at login) |

---

## Architecture Overview

### How Everything Connects

```
┌─────────────────────────────────────────────────────┐
│                    HealthGremlinApp                   │
│  (Entry point: MenuBarExtra + AppDelegate)           │
│                                                       │
│  On launch:                                           │
│  1. Set .accessory policy (no dock icon)              │
│  2. Start TimerCoordinator                            │
│  3. Register global hotkeys                           │
└─────────────┬──────────────────┬─────────────────────┘
              │                  │
              ▼                  ▼
┌──────────────────┐  ┌──────────────────┐
│  MenuBarView     │  │  HotkeyManager   │
│  (Dropdown UI)   │  │  (Carbon API)    │
│                  │  │                  │
│  • Status        │  │  • Global hotkey │
│  • Pause/Resume  │  │    registration  │
│  • Settings...   │  │  • Self-report   │
│  • Quit          │  │    dispatch      │
└────────┬─────────┘  └────────┬─────────┘
         │                     │
         ▼                     ▼
┌──────────────────────────────────────────┐
│           TimerCoordinator               │
│  (The brain — singleton)                 │
│                                          │
│  • 5 independent category timers         │
│  • Randomized jitter (±25%)              │
│  • 10-min minimum gap enforcement        │
│  • 5-min grace period on launch          │
│  • Per-category escalation tracking      │
│  • Auto-dismiss after 3 min             │
│  • Pause/resume with timed auto-resume   │
│  • Debug mode (30x / 3x speed)           │
└────────────────────┬─────────────────────┘
                     │
                     │ fires reminder
                     ▼
┌──────────────────────────────────────────┐
│           WindowManager                  │
│  (Floating NSPanel)                      │
│                                          │
│  • Non-activating (doesn't steal focus)  │
│  • Floats above all windows              │
│  • Visible on all Spaces/desktops        │
│  • Transparent background                │
│  • Position from UserDefaults            │
└────────────────────┬─────────────────────┘
                     │
                     │ hosts
                     ▼
┌──────────────────────────────────────────┐
│        ReminderOverlayView               │
│  ┌─────────────────┐ ┌────────────────┐  │
│  │  SpeechBubble   │ │   Character    │  │
│  │  • Category     │ │   • Tier-based │  │
│  │  • Message      │ │     appearance │  │
│  │  • Tier badge   │ │   • Animations │  │
│  │  • Buttons      │ │     at Tier 3  │  │
│  └─────────────────┘ └────────────────┘  │
└──────────────────────────────────────────┘
```

### Data Flow

```
User ignores reminder
    → auto-dismiss (3 min) or clicks "Delay"
    → TimerCoordinator.handleDelay()
    → escalationTiers[category] advances
    → schedules snooze (5 min)
    → fires again at higher tier

User clicks "I did the thing"
    → TimerCoordinator.handleAcknowledge()
    → escalationTiers[category] = .jarvis
    → schedules next reminder (full interval)

User presses hotkey (e.g., ⌘⇧W)
    → Carbon event handler fires
    → HotkeyManager.handleHotkey()
    → TimerCoordinator.selfReport(.water)
    → escalation reset, timer restarted
    → brief quip shown (2 sec)

User changes settings
    → SettingsView.applySettings()
    → UserDefaults updated
    → TimerCoordinator.restartAllTimers()
    → HotkeyManager.registerHotkeys()

Demo mode (menu bar → 🎬 Demo Mode → category)
    → TimerCoordinator.startDemo(category:)
    → Pauses normal timers, saves pause state
    → Shows Tier 1 via WindowManager
    → "Next Tier" → demoCycleNext()
        → Advances tier, gets new message
        → WindowManager.updateReminder() (in-place swap)
    → "Exit Demo" → stopDemo()
        → Dismisses overlay, restores timer state
```

---

## All Source Files

```
healthgremlin/
├── health-gremlin-spec.md                    # Original product spec
├── health-gremlin-kickoff.md                 # Claude Code setup instructions
├── health-gremlin-reference.md               # This file
└── HealthGremlin/
    ├── Package.swift                         # SPM config (macOS 14+, no deps)
    ├── build-and-run.sh                      # Build + bundle + launch script
    └── HealthGremlin/
        ├── HealthGremlinApp.swift             # @main entry, AppDelegate, MenuBarExtra
        ├── Info.plist                         # LSUIElement = true
        ├── Models/
        │   ├── ReminderCategory.swift         # 5 reminder types + intervals from UserDefaults
        │   ├── EscalationTier.swift           # 3 tiers: jarvis → concerned → gremlin
        │   ├── TimerCoordinator.swift         # Scheduling engine (jitter, gaps, escalation)
        │   ├── MessageBank.swift              # JSON loader + random message selection
        │   └── HotkeyConfig.swift             # Keyboard shortcut model (Codable)
        ├── Views/
        │   ├── FloatingCharacterView.swift    # Gremlin visual (shapes, colors, animations)
        │   ├── SpeechBubbleView.swift         # Message bubble + action buttons
        │   ├── ReminderOverlayView.swift      # Combined character + bubble overlay
        │   ├── MenuBarView.swift              # Menu bar dropdown (pause, settings, quit)
        │   ├── SettingsView.swift             # Preferences panel (intervals, hotkeys, etc.)
        │   └── HotkeyRecorderView.swift       # Interactive keyboard shortcut recorder
        ├── Resources/
        │   ├── MessageBank.json               # All messages (5 categories x 3 tiers x 6-7 each)
        │   └── Assets.xcassets/               # Menu bar icon + app icon
        └── Utilities/
            ├── WindowManager.swift            # NSPanel management (floating overlay)
            └── HotkeyManager.swift            # Global hotkeys via Carbon API
```

---

## Slack Message Template

Here's a ready-to-share message for telling other Gladiators about Health Gremlin:

---

**🐸 Introducing Health Gremlin — your new desktop health nag**

I built a little macOS app called Health Gremlin that reminds you to drink water, stand up, take walks, and do quick exercises throughout the day.

**How it works:**
- Lives in your menu bar — no dock icon, no window clutter
- A floating character pops up with reminders at randomized intervals
- If you acknowledge it, it goes away happy. If you ignore it... it escalates.
- Starts as a calm British butler ("Might I suggest hydration?") and ends as a chaotic gremlin ("DRINK WATER OR I WILL HAUNT YOUR DESKTOP FOREVER. I LIVE HERE NOW.")
- Fully customizable intervals, keyboard shortcuts, and screen position
- Built-in Demo Mode to preview all 3 escalation tiers live
- 100% local, 100% silent, 0% data collection

**To install it:**
1. Clone the repo / copy the project folder to your Mac
2. Open terminal, `cd` into the `HealthGremlin` folder
3. Run `bash build-and-run.sh`
4. Grant Accessibility permission in System Settings (for keyboard shortcuts)
5. That's it — look for the gremlin in your menu bar!

**Requirements:** macOS 14 (Sonoma) or later, Xcode Command Line Tools

Built entirely with Claude Code. The whole thing is Swift/SwiftUI, no dependencies, no tracking. Just you and the gremlin. 🐸

---

*Last updated: February 2026*
*Version: 1.0*
