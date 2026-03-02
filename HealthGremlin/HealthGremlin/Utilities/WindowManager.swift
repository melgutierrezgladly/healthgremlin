import SwiftUI
import AppKit

// MARK: - WindowManager
// Manages the floating overlay window where the gremlin character appears.
//
// WHY NSPanel instead of NSWindow?
// NSPanel is a special kind of window designed for auxiliary/utility purposes.
// Key behaviors we need:
// - Floats above regular windows (like Clippy did)
// - Does NOT steal focus from whatever app you're working in
// - Visible on ALL desktops/Spaces (so it follows you around)
// - Click-through for the background (only buttons are interactive)

class WindowManager: ObservableObject {
    // The floating panel that holds our gremlin character
    private var panel: NSPanel?

    // Published so SwiftUI views can react to show/hide state
    @Published var isShowingReminder = false

    // Current reminder data being displayed
    @Published var currentMessage: String = ""
    @Published var currentCategory: String = ""
    @Published var currentTier: Int = 1

    // Callbacks for button actions — these get wired up by the app
    var onAcknowledge: (() -> Void)?
    var onDelay: (() -> Void)?
    var onNextTier: (() -> Void)?  // Used in demo mode to cycle tiers

    // Singleton so the whole app shares one window manager.
    // (There should only ever be one floating gremlin on screen.)
    static let shared = WindowManager()

    private init() {}

    // MARK: - Show the gremlin with a reminder message

    func showReminder(message: String, category: String, tier: Int) {
        currentMessage = message
        currentCategory = category
        currentTier = tier
        isShowingReminder = true

        // Run on the main thread — UI work must always happen on main
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if self.panel == nil {
                self.createPanel()
            } else {
                // Reposition in case user changed the position setting
                self.repositionPanel()
            }

            self.updatePanelContent()
            self.panel?.orderFront(nil)  // Show the window (without stealing focus)
        }
    }

    // MARK: - Update the gremlin in-place (used by demo mode)

    /// Updates the displayed message, category, and tier without dismissing/recreating.
    /// The panel stays visible — content just swaps.
    func updateReminder(message: String, category: String, tier: Int) {
        currentMessage = message
        currentCategory = category
        currentTier = tier

        DispatchQueue.main.async { [weak self] in
            self?.updatePanelContent()
        }
    }

    // MARK: - Dismiss the gremlin

    func dismissReminder() {
        isShowingReminder = false
        DispatchQueue.main.async { [weak self] in
            self?.panel?.orderOut(nil)  // Hide the window
        }
    }

    // MARK: - Create the floating panel

    private func createPanel() {
        // Calculate position based on user's preference (from Settings)
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let panelWidth: CGFloat = 340
        let panelHeight: CGFloat = 260
        let padding: CGFloat = 20

        let position = UserDefaults.standard.string(forKey: "characterPosition") ?? "bottomRight"

        let panelX: CGFloat
        let panelY: CGFloat

        switch position {
        case "bottomLeft":
            panelX = screenFrame.minX + padding
            panelY = screenFrame.minY + padding
        case "topRight":
            panelX = screenFrame.maxX - panelWidth - padding
            panelY = screenFrame.maxY - panelHeight - padding
        case "topLeft":
            panelX = screenFrame.minX + padding
            panelY = screenFrame.maxY - panelHeight - padding
        default: // "bottomRight"
            panelX = screenFrame.maxX - panelWidth - padding
            panelY = screenFrame.minY + padding
        }

        let panelRect = NSRect(
            x: panelX,
            y: panelY,
            width: panelWidth,
            height: panelHeight
        )

        // Create the panel with specific style flags:
        // - .nonactivatingPanel: won't steal focus from your current app
        // - .borderless: no title bar or window chrome
        // - .hudWindow: gives it a floating utility window appearance
        let panel = NSPanel(
            contentRect: panelRect,
            styleMask: [.borderless, .nonactivatingPanel, .hudWindow],
            backing: .buffered,
            defer: false
        )

        // MARK: Panel configuration — these are the magic settings

        // Float above ALL other windows (even full-screen apps won't cover it)
        panel.level = .floating

        // Appear on ALL desktops/Spaces — the gremlin follows you everywhere
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Transparent background — the SwiftUI view handles its own background
        panel.isOpaque = false
        panel.backgroundColor = .clear

        // Don't show in the Window menu or Mission Control
        panel.hidesOnDeactivate = false
        panel.isExcludedFromWindowsMenu = true

        // Allow the panel to become key (receive clicks) even though
        // it's non-activating (won't steal focus from other apps)
        panel.becomesKeyOnlyIfNeeded = true

        // Store reference
        self.panel = panel
    }

    // MARK: - Reposition the panel based on current settings

    private func repositionPanel() {
        guard let panel = self.panel, let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let panelWidth = panel.frame.width
        let panelHeight = panel.frame.height
        let padding: CGFloat = 20

        let position = UserDefaults.standard.string(forKey: "characterPosition") ?? "bottomRight"

        let panelX: CGFloat
        let panelY: CGFloat

        switch position {
        case "bottomLeft":
            panelX = screenFrame.minX + padding
            panelY = screenFrame.minY + padding
        case "topRight":
            panelX = screenFrame.maxX - panelWidth - padding
            panelY = screenFrame.maxY - panelHeight - padding
        case "topLeft":
            panelX = screenFrame.minX + padding
            panelY = screenFrame.maxY - panelHeight - padding
        default: // "bottomRight"
            panelX = screenFrame.maxX - panelWidth - padding
            panelY = screenFrame.minY + padding
        }

        panel.setFrameOrigin(NSPoint(x: panelX, y: panelY))
    }

    // MARK: - Update the panel's SwiftUI content

    private func updatePanelContent() {
        guard let panel = self.panel else { return }

        // Create our SwiftUI view and host it in the panel.
        // NSHostingView bridges SwiftUI into an AppKit window.
        let contentView = ReminderOverlayView(windowManager: self)
        let hostingView = NSHostingView(rootView: contentView)

        // Make the hosting view's background transparent
        hostingView.layer?.backgroundColor = .clear

        panel.contentView = hostingView

        // Resize the panel to fit the content
        let panelWidth: CGFloat = 340
        let panelHeight: CGFloat = 260
        var frame = panel.frame
        frame.size = NSSize(width: panelWidth, height: panelHeight)
        panel.setFrame(frame, display: true)
    }
}
