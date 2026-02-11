# Health Gremlin — Claude Code Kickoff & Project Setup

---

## Part 1: Claude Project Setup

### Project Name
**Health Gremlin**

### Project Description
A native macOS menu bar app that delivers health reminders (stand, sit, water, walk, dance, calisthenics) via a floating Clippy-style character with an escalating personality — from polished JARVIS to unhinged gremlin.

### Custom Instructions (paste into the Project's system prompt)

```
You are helping build Health Gremlin, a native macOS menu bar app written in Swift/SwiftUI.

## Context
- This is a personal project for a non-developer building with Claude Code
- Target: macOS 14+ (Sonoma)
- No App Store distribution — local build only
- No external dependencies — pure Swift/SwiftUI

## Architecture
- SwiftUI for menu bar app and settings panel
- NSWindow/NSPanel for the floating character overlay (non-activating, floats above other windows, visible on all Spaces)
- Central TimerCoordinator manages all reminder scheduling with randomized jitter and minimum gap enforcement
- Global keyboard shortcuts via CGEvent tap or similar macOS API
- Message bank stored as structured Swift dictionary or bundled JSON

## Key Design Decisions
- SILENT — no audio, ever
- Visual only — floating character with speech bubble
- 3-tier escalation: JARVIS → Concerned JARVIS → Unhinged Gremlin
- "Delay" button counts as ignored (advances escalation tier)
- "I did the thing" button resets escalation to Tier 1
- Keyboard shortcuts allow self-reporting activities proactively
- No tracking, analytics, or data collection

## Personality Voice
- Tier 1 (JARVIS): Calm British butler. Dry wit. Polite but sardonic. Think: "Might I suggest hydration? Your cells have been remarkably patient."
- Tier 2 (Concerned JARVIS): Passive-aggressive. Still composed but clearly losing patience. Think: "I've now asked twice. This is becoming a pattern."
- Tier 3 (Unhinged Gremlin): Full chaos. ALL CAPS energy. Dramatic. Absurd. Think: "STAND UP RIGHT NOW. I WILL WIGGLE. YOU DO NOT WANT ME TO WIGGLE."

## Code Style Preferences
- Clear, well-commented code (the developer is learning Swift through this project)
- Explain non-obvious Swift/macOS patterns when introducing them
- Prefer readability over cleverness
- When making architecture decisions, briefly explain WHY
- If something requires specific macOS permissions or entitlements, flag it clearly

## Current Status
Check the spec document and any existing code before starting work. Ask clarifying questions if the spec is ambiguous rather than guessing.
```

### Files to Upload to the Project
1. **health-gremlin-spec.md** — The full product spec (the file I just created)
2. Any visual references or sketches of the character design (when you have them)
3. Future: code files, bug notes, or iteration docs as the project evolves

---

## Part 2: Claude Code Kickoff Prompt

Copy and paste this into Claude Code when you're ready to start building:

---

```
I want to build the Health Gremlin app. Please read the spec document I've provided (health-gremlin-spec.md) thoroughly before doing anything.

Here's how I'd like to approach this:

**Phase 1: Project scaffolding**
- Set up the Swift package or Xcode project structure
- Get a basic menu bar app running that I can see in my macOS menu bar
- Confirm it builds and launches successfully

**Phase 2: Floating character overlay**
- Create the floating window that appears on screen (Clippy-style)
- It should float above other windows, not steal focus, and be visible on all desktops
- Start with a simple placeholder design (circle with a face, speech bubble with hardcoded text)
- Add the "I did the thing" and "Delay" buttons

**Phase 3: Timer system**
- Build the TimerCoordinator with smart timing (randomized jitter, minimum gaps between reminders)
- Wire it up so reminders actually trigger the floating character to appear
- Implement the 3-tier escalation logic (JARVIS → Concerned → Gremlin)

**Phase 4: Message bank**
- Generate the full message bank (5-8 messages per category per tier)
- Maintain the personality voice described in the spec
- Wire random message selection into the reminder system

**Phase 5: Keyboard shortcuts & settings**
- Register global hotkeys for self-reporting
- Build the settings panel (interval sliders, pause duration, launch at login, character position)

**Phase 6: Polish**
- Character visual design with tier-based appearance changes
- Auto-dismiss behavior (3-minute timeout)
- Edge cases and QA

Please start with Phase 1. Walk me through any decisions you're making and flag anything that needs macOS permissions or entitlements. I'm not a Swift developer, so explain things as you go — but don't over-explain basics like what a variable is. Treat me like a smart person learning a new tool.

Before you start writing code, confirm your understanding of the spec and tell me if you have any questions.
```

---

## Tips for Working with Claude Code on This

1. **Work in phases.** Don't let it try to build everything at once. Confirm each phase works before moving on.

2. **Test after each phase.** After Phase 1, actually build and run the app. Make sure you see the menu bar icon before moving to Phase 2. This prevents compounding errors.

3. **If something breaks,** paste the error message directly into Claude Code. It's very good at debugging Swift compiler errors if you give it the exact output.

4. **Save your progress.** After each successful phase, consider committing to a git repo so you can roll back if a later phase breaks things. You can ask Claude Code to set up git for you.

5. **The floating window is the hardest part.** NSWindow/NSPanel behavior on macOS can be finicky. If Phase 2 gives you trouble, that's normal — it's the trickiest piece of macOS development in this project.

6. **You can always come back here.** If you hit a wall or want to iterate on the spec, bring the question back to this Project and we can update the spec together before sending Claude Code in a new direction.
