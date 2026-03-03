import Foundation
import Combine

// MARK: - TimerCoordinator
// The brain of Health Gremlin. Manages all reminder scheduling.
//
// Responsibilities:
// - Runs independent timers for each reminder category
// - Adds randomized jitter so reminders aren't robotically predictable
// - Enforces a 10-minute minimum gap between ANY two reminders
// - Starts with a 5-minute grace period after launch
// - Tracks escalation tier per category
// - Handles auto-dismiss after 3 minutes of no response
// - Pauses/resumes all timers
//
// HOW THE TIMING WORKS:
// Each category has a timer that fires after a randomized interval
// (e.g., water fires somewhere between 20-40 minutes).
// When a timer fires, we check if another reminder was shown recently
// (within 10 minutes). If so, we delay this one by a few minutes.
// This prevents the user from getting bombarded with back-to-back reminders.

class TimerCoordinator: ObservableObject {
    // Singleton — one coordinator for the whole app
    static let shared = TimerCoordinator()

    // MARK: - Published state (UI can observe these)

    /// Whether all reminders are currently paused
    @Published var isPaused = false

    /// The category currently being shown (nil if no reminder is active)
    @Published var activeCategory: ReminderCategory?

    // MARK: - Internal state

    /// Per-category escalation tier tracking
    /// Starts at Tier 1 (JARVIS) for all categories
    private var escalationTiers: [ReminderCategory: EscalationTier] = {
        var tiers: [ReminderCategory: EscalationTier] = [:]
        for category in ReminderCategory.allCases {
            tiers[category] = .jarvis
        }
        return tiers
    }()

    /// Per-category scheduled timers
    private var categoryTimers: [ReminderCategory: Timer] = [:]

    /// When the last reminder was shown (for enforcing minimum gap)
    private var lastReminderTime: Date?

    /// Timer for auto-dismissing the current reminder after 3 minutes
    private var autoDismissTimer: Timer?

    /// Timer for the grace period after launch
    private var graceTimer: Timer?

    /// Whether we're still in the initial grace period
    private var inGracePeriod = true

    /// Minimum gap between any two reminders (in seconds)
    private let minimumGapSeconds: TimeInterval = 10 * 60  // 10 minutes

    /// Grace period after launch before first reminder (in seconds)
    private let gracePeriodSeconds: TimeInterval = 5 * 60  // 5 minutes

    /// How long before auto-dismiss (in seconds)
    private let autoDismissSeconds: TimeInterval = 3 * 60  // 3 minutes

    /// Delay snooze duration (in seconds)
    private let snoozeSeconds: TimeInterval = 5 * 60  // 5 minutes

    // MARK: - Debug mode
    // Set to true for faster timers during development/testing.
    // Uses separate scaling for different timer types so the app
    // is testable without being so fast you can't interact with it.
    @Published var debugMode = false

    /// Scales SCHEDULING intervals (grace period, reminder timers, gaps).
    /// 30x faster so you don't wait 45 minutes for a reminder.
    private func scaled(_ interval: TimeInterval) -> TimeInterval {
        return debugMode ? interval / 30.0 : interval
    }

    /// Scales INTERACTION intervals (auto-dismiss, snooze).
    /// Only 3x faster so you have time to actually read and click buttons.
    /// Auto-dismiss: 3 min → 60 sec. Snooze: 5 min → ~100 sec.
    private func scaledInteraction(_ interval: TimeInterval) -> TimeInterval {
        return debugMode ? interval / 3.0 : interval
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Start the system

    /// Call this once when the app launches to begin the reminder system.
    /// Waits for the grace period, then starts all category timers.
    func start() {
        print("⏱ TimerCoordinator: Starting with \(scaled(gracePeriodSeconds))s grace period...")
        inGracePeriod = true

        // Grace period timer — don't nag the user immediately after opening
        graceTimer = Timer.scheduledTimer(withTimeInterval: scaled(gracePeriodSeconds), repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.inGracePeriod = false
            guard !self.isPaused else {
                print("⏱ TimerCoordinator: Grace period over but paused — waiting for resume")
                return
            }
            print("⏱ TimerCoordinator: Grace period over. Starting all timers.")
            self.startAllCategoryTimers()
        }
    }

    /// Starts (or restarts) timers for all active categories
    private func startAllCategoryTimers() {
        for category in ReminderCategory.allCases {
            guard category.isCurrentlyActive else { continue }
            scheduleTimer(for: category)
        }
    }

    /// Public method to restart all timers (called when settings change).
    /// Cancels existing timers and reschedules with new intervals.
    func restartAllTimers() {
        for (_, timer) in categoryTimers {
            timer.invalidate()
        }
        categoryTimers.removeAll()
        startAllCategoryTimers()
        print("⏱ All timers restarted with new intervals")
    }

    // MARK: - Timer scheduling

    /// Schedule the next reminder for a specific category.
    /// Uses randomized jitter within the category's min/max range.
    func scheduleTimer(for category: ReminderCategory) {
        // Cancel any existing timer for this category
        categoryTimers[category]?.invalidate()

        guard !isPaused else { return }
        guard category.isCurrentlyActive else { return }

        // Calculate a random interval within the category's range
        let interval = TimeInterval.random(in: category.minimumInterval...category.maximumInterval)
        let scaledInterval = scaled(interval)

        print("⏱ Scheduling \(category.rawValue) in \(Int(scaledInterval))s")

        categoryTimers[category] = Timer.scheduledTimer(
            withTimeInterval: scaledInterval,
            repeats: false
        ) { [weak self] _ in
            self?.fireReminder(for: category)
        }
    }

    // MARK: - Firing reminders

    /// Called when a category's timer fires. Checks for minimum gap,
    /// then shows the reminder via WindowManager.
    private func fireReminder(for category: ReminderCategory) {
        guard !isPaused else {
            print("⏱ \(category.rawValue): Fired while paused — ignoring")
            return
        }
        guard category.isCurrentlyActive else { return }

        // Check minimum gap — don't pile reminders on top of each other
        if let lastTime = lastReminderTime {
            let elapsed = Date().timeIntervalSince(lastTime)
            if elapsed < scaled(minimumGapSeconds) {
                // Too soon after the last reminder — delay this one
                let delay = scaled(minimumGapSeconds) - elapsed + 30  // Add 30s buffer
                print("⏱ \(category.rawValue): Too soon after last reminder. Delaying \(Int(delay))s")

                categoryTimers[category] = Timer.scheduledTimer(
                    withTimeInterval: delay,
                    repeats: false
                ) { [weak self] _ in
                    guard let self = self, !self.isPaused else { return }
                    self.fireReminder(for: category)
                }
                return
            }
        }

        // Don't show a new reminder if one is already visible
        if WindowManager.shared.isShowingReminder {
            // Retry in 2 minutes
            let retryDelay = scaled(2 * 60)
            print("⏱ \(category.rawValue): Another reminder active. Retrying in \(Int(retryDelay))s")

            categoryTimers[category] = Timer.scheduledTimer(
                withTimeInterval: retryDelay,
                repeats: false
            ) { [weak self] _ in
                guard let self = self, !self.isPaused else { return }
                self.fireReminder(for: category)
            }
            return
        }

        // Final pause check before showing (belt-and-suspenders)
        guard !isPaused else {
            print("⏱ \(category.rawValue): Pause detected at show time — aborting")
            return
        }

        // Get the current escalation tier for this category
        let tier = escalationTiers[category] ?? .jarvis

        // Pick a random message from the MessageBank (no immediate repeats)
        let message = MessageBank.shared.getMessage(for: category, tier: tier)

        // Show the reminder!
        activeCategory = category
        lastReminderTime = Date()

        print("🔔 Firing \(category.rawValue) reminder at \(tier.name)")

        WindowManager.shared.showReminder(
            message: message,
            category: "\(category.emoji) \(category.rawValue) Reminder",
            tier: tier.rawValue
        )

        // Wire up the button callbacks
        WindowManager.shared.onAcknowledge = { [weak self] in
            self?.handleAcknowledge(for: category)
        }
        WindowManager.shared.onDelay = { [weak self] in
            self?.handleDelay(for: category)
        }

        // Start auto-dismiss timer (3 minutes)
        startAutoDismissTimer(for: category)
    }

    // MARK: - Button handlers

    /// Called when user hits "I did the thing" — resets escalation and timer.
    /// Also resets related categories (e.g., dancing satisfies stand/sit and walk).
    func handleAcknowledge(for category: ReminderCategory) {
        print("✅ \(category.rawValue): Acknowledged! Resetting to Tier 1.")

        // Reset escalation back to JARVIS (Tier 1)
        escalationTiers[category] = .jarvis

        // Cancel auto-dismiss timer
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil

        // Clear active category
        activeCategory = nil

        // Restart the timer for this category (full interval)
        scheduleTimer(for: category)

        // Reset related categories too — e.g., dancing means you stood and moved
        for related in category.alsoSatisfies {
            escalationTiers[related] = .jarvis
            scheduleTimer(for: related)
            print("   ↳ Also reset \(related.rawValue) timer")
        }
    }

    /// Called when user hits "Delay" — advances escalation, snoozes for 5 min
    func handleDelay(for category: ReminderCategory) {
        let currentTier = escalationTiers[category] ?? .jarvis
        let nextTier = currentTier.next

        print("⏳ \(category.rawValue): Delayed. Escalating from \(currentTier.name) to \(nextTier.name). Snoozing \(Int(scaledInteraction(snoozeSeconds)))s.")

        // Advance escalation tier
        escalationTiers[category] = nextTier

        // Cancel auto-dismiss timer
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil

        // Clear active category
        activeCategory = nil

        // Don't schedule snooze if paused
        guard !isPaused else {
            print("⏱ \(category.rawValue): Paused — skipping snooze timer")
            return
        }

        // Schedule snooze timer (fires again in 5 minutes at the higher tier)
        // Uses scaledInteraction so snooze isn't absurdly fast in debug mode
        categoryTimers[category]?.invalidate()
        categoryTimers[category] = Timer.scheduledTimer(
            withTimeInterval: scaledInteraction(snoozeSeconds),
            repeats: false
        ) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            self.fireReminder(for: category)
        }
    }

    // MARK: - Auto-dismiss

    /// Starts a 3-minute timer. If the user doesn't respond, the reminder
    /// auto-dismisses and counts as ignored (escalation advances).
    private func startAutoDismissTimer(for category: ReminderCategory) {
        autoDismissTimer?.invalidate()

        autoDismissTimer = Timer.scheduledTimer(
            withTimeInterval: scaledInteraction(autoDismissSeconds),
            repeats: false
        ) { [weak self] _ in
            guard let self = self else { return }

            // Don't auto-dismiss during demo mode or while paused
            guard !self.inDemoMode else { return }
            guard !self.isPaused else { return }

            print("⏱ \(category.rawValue): Auto-dismissed after 3 minutes (counts as ignored)")

            // Treat as a delay — escalate and snooze
            self.handleDelay(for: category)
            WindowManager.shared.dismissReminder()
        }
    }

    // MARK: - Pause / Resume

    /// Timer for auto-resuming after a timed pause
    private var pauseResumeTimer: Timer?

    /// Pause all reminders. If `duration` is provided (in seconds),
    /// auto-resume after that many seconds. If nil, pause indefinitely.
    func pause(forDuration duration: TimeInterval? = nil) {
        isPaused = true

        // Cancel all timers — belt-and-suspenders: count what we're cancelling
        let timerCount = categoryTimers.count
        for (_, timer) in categoryTimers {
            timer.invalidate()
        }
        categoryTimers.removeAll()
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil
        graceTimer?.invalidate()
        graceTimer = nil
        pauseResumeTimer?.invalidate()
        pauseResumeTimer = nil

        // Dismiss any active reminder
        WindowManager.shared.dismissReminder()
        activeCategory = nil

        if let duration = duration {
            // Schedule auto-resume
            pauseResumeTimer = Timer.scheduledTimer(
                withTimeInterval: duration,
                repeats: false
            ) { [weak self] _ in
                print("⏸ Timed pause expired — auto-resuming")
                self?.resume()
            }
            let minutes = Int(duration / 60)
            print("⏸ PAUSED for \(minutes) minutes (cancelled \(timerCount) timers)")
        } else {
            print("⏸ PAUSED until manually resumed (cancelled \(timerCount) timers)")
        }
    }

    /// Resume all reminders
    func resume() {
        isPaused = false
        inGracePeriod = false
        pauseResumeTimer?.invalidate()
        pauseResumeTimer = nil
        startAllCategoryTimers()
        print("▶️ RESUMED — all category timers restarted")
    }

    // MARK: - Self-reporting (keyboard shortcuts)

    /// Called when the user proactively reports an activity via keyboard shortcut.
    /// Resets the timer and escalation for the relevant category.
    /// Also resets related categories (e.g., walking satisfies stand/sit).
    /// If paused, still resets escalation but doesn't schedule a new timer.
    func selfReport(category: ReminderCategory) {
        print("🎯 Self-reported: \(category.rawValue)\(isPaused ? " (paused — timer not restarted)" : "")")

        // Reset escalation to Tier 1
        escalationTiers[category] = .jarvis

        // Restart the timer with a full interval (scheduleTimer checks isPaused)
        scheduleTimer(for: category)

        // Reset related categories too
        for related in category.alsoSatisfies {
            escalationTiers[related] = .jarvis
            scheduleTimer(for: related)
            print("   ↳ Also reset \(related.rawValue) timer")
        }
    }

    // MARK: - Coworking Mode

    /// Call when coworking mode changes to cancel/restart appropriate timers
    func handleCoworkingModeChange() {
        // Cancel timers for now-disabled categories
        for category in ReminderCategory.allCases {
            if !category.isCurrentlyActive {
                categoryTimers[category]?.invalidate()
                categoryTimers.removeValue(forKey: category)
                escalationTiers[category] = .jarvis
            }
        }
        // Start timers for any newly-enabled categories
        if !isPaused && !inGracePeriod {
            startAllCategoryTimers()
        }
        print("⏱ Coworking mode changed — timers updated")
    }

    // MARK: - Demo Mode
    // Allows cycling through all 3 escalation tiers with real messages
    // and animations for recording a demo video.

    /// Whether the app is currently in demo mode
    @Published var inDemoMode = false

    /// The category being demoed
    private var demoCategory: ReminderCategory?

    /// The current demo tier (tracked separately from real escalation)
    private var demoTier: EscalationTier = .jarvis

    /// Whether normal timers were paused before demo started
    private var wasPausedBeforeDemo = false

    /// Start demo mode — shows the overlay at Tier 1 for the given category
    func startDemo(category: ReminderCategory) {
        guard !inDemoMode else { return }
        guard category.isCurrentlyActive else {
            print("🎬 Demo mode: \(category.rawValue) is disabled in coworking mode")
            return
        }

        print("🎬 Demo mode: Starting with \(category.rawValue)")

        // Remember if we were paused so we can restore that state
        wasPausedBeforeDemo = isPaused

        // Cancel all normal timers so they don't interfere
        for (_, timer) in categoryTimers {
            timer.invalidate()
        }
        categoryTimers.removeAll()
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil

        // Dismiss any active real reminder
        if isShowingRealReminder {
            WindowManager.shared.dismissReminder()
            activeCategory = nil
        }

        // Enter demo mode
        inDemoMode = true
        demoCategory = category
        demoTier = .jarvis

        // Show the first tier
        let message = MessageBank.shared.getMessage(for: category, tier: demoTier)
        WindowManager.shared.showReminder(
            message: message,
            category: "\(category.emoji) \(category.rawValue) Reminder",
            tier: demoTier.rawValue
        )

        // Wire up demo callbacks
        WindowManager.shared.onAcknowledge = { [weak self] in
            self?.stopDemo()
        }
        WindowManager.shared.onDelay = nil
        WindowManager.shared.onNextTier = { [weak self] in
            self?.demoCycleNext()
        }
    }

    /// Advance to the next tier in demo mode
    func demoCycleNext() {
        guard inDemoMode, let category = demoCategory else { return }

        // Advance the tier
        demoTier = demoTier.next

        print("🎬 Demo mode: Cycling to \(demoTier.name)")

        // Get a new message for the new tier
        let message = MessageBank.shared.getMessage(for: category, tier: demoTier)

        // Update the overlay in-place (no dismiss/recreate)
        WindowManager.shared.updateReminder(
            message: message,
            category: "\(category.emoji) \(category.rawValue) Reminder",
            tier: demoTier.rawValue
        )

        // At Tier 3, the "Next Tier" button disappears (handled by SpeechBubbleView)
        // but the callbacks stay the same — onAcknowledge exits demo
    }

    /// Exit demo mode and restore normal operation
    func stopDemo() {
        guard inDemoMode else { return }

        print("🎬 Demo mode: Exiting")

        inDemoMode = false
        demoCategory = nil
        demoTier = .jarvis

        // Clear demo callbacks
        WindowManager.shared.onAcknowledge = nil
        WindowManager.shared.onDelay = nil
        WindowManager.shared.onNextTier = nil

        // Dismiss the overlay
        WindowManager.shared.dismissReminder()
        activeCategory = nil

        // Restore normal timer operation
        if wasPausedBeforeDemo {
            // They were paused before — keep them paused
            isPaused = true
        } else {
            // Restart normal timers
            isPaused = false
            startAllCategoryTimers()
        }
    }

    /// Convenience: whether a real (non-demo) reminder is currently on screen
    private var isShowingRealReminder: Bool {
        return WindowManager.shared.isShowingReminder && !inDemoMode
    }

}
