import SwiftUI
import ServiceManagement

// MARK: - SettingsView
// The preferences panel accessible from the menu bar dropdown.
// Lets the user customize reminder intervals, character position,
// keyboard shortcuts, and launch-at-login behavior.
//
// Settings are stored in UserDefaults so they persist between launches.

struct SettingsView: View {
    // MARK: - Per-category interval settings (stored in minutes)
    @AppStorage("interval_water") private var waterInterval: Double = 30
    @AppStorage("interval_standSit") private var standSitInterval: Double = 45
    @AppStorage("interval_walk") private var walkInterval: Double = 90
    @AppStorage("interval_dance") private var danceInterval: Double = 120
    @AppStorage("interval_calisthenics") private var calisthenicsInterval: Double = 120

    // MARK: - General settings
    @AppStorage("characterPosition") private var characterPosition: String = "bottomRight"
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    @AppStorage("debugMode") private var debugMode: Bool = false

    // MARK: - Custom hotkey configs
    // These are loaded from UserDefaults on appear and saved on Apply.
    @State private var hotkeyStood: HotkeyConfig = HotkeyConfig.defaults["stood"]!
    @State private var hotkeySat: HotkeyConfig = HotkeyConfig.defaults["sat"]!
    @State private var hotkeyWater: HotkeyConfig = HotkeyConfig.defaults["water"]!
    @State private var hotkeyWalked: HotkeyConfig = HotkeyConfig.defaults["walked"]!
    @State private var hotkeyPauseResume: HotkeyConfig = HotkeyConfig.defaults["pauseResume"]!

    // For closing the window
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // --- Header ---
            HStack {
                Text("⚙ Health Gremlin Settings")
                    .font(.title2.bold())
                Spacer()
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // --- Reminder Intervals ---
                    settingsSection("Reminder Intervals") {
                        intervalSlider(
                            label: "💧 Water",
                            value: $waterInterval,
                            range: 10...60,
                            step: 5
                        )
                        intervalSlider(
                            label: "🧍 Stand/Sit",
                            value: $standSitInterval,
                            range: 15...90,
                            step: 5
                        )
                        intervalSlider(
                            label: "🚶 Walk",
                            value: $walkInterval,
                            range: 30...180,
                            step: 15
                        )
                        intervalSlider(
                            label: "💃 Dance",
                            value: $danceInterval,
                            range: 30...240,
                            step: 15
                        )
                        intervalSlider(
                            label: "💪 Calisthenics",
                            value: $calisthenicsInterval,
                            range: 30...240,
                            step: 15
                        )
                    }

                    // --- Character Position ---
                    settingsSection("Character Position") {
                        Picker("Position", selection: $characterPosition) {
                            Text("↘ Bottom Right").tag("bottomRight")
                            Text("↙ Bottom Left").tag("bottomLeft")
                            Text("↗ Top Right").tag("topRight")
                            Text("↖ Top Left").tag("topLeft")
                        }
                        .pickerStyle(.radioGroup)
                    }

                    // --- General ---
                    settingsSection("General") {
                        Toggle("Launch at login", isOn: $launchAtLogin)
                            .onChange(of: launchAtLogin) { _, newValue in
                                setLaunchAtLogin(newValue)
                            }

                        Toggle("🧪 Debug mode (fast timers)", isOn: $debugMode)
                            .onChange(of: debugMode) { _, newValue in
                                TimerCoordinator.shared.debugMode = newValue
                            }
                    }

                    // --- Keyboard Shortcuts (Editable!) ---
                    settingsSection("Keyboard Shortcuts") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Click a field and press your desired key combo.")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            HotkeyRecorderView(label: "I just stood up", config: $hotkeyStood)
                            HotkeyRecorderView(label: "I just sat down", config: $hotkeySat)
                            HotkeyRecorderView(label: "I drank water", config: $hotkeyWater)
                            HotkeyRecorderView(label: "I walked/moved", config: $hotkeyWalked)
                            HotkeyRecorderView(label: "Pause/resume all", config: $hotkeyPauseResume)

                            Button("Reset to Defaults") {
                                resetHotkeysToDefaults()
                            }
                            .font(.caption)
                            .padding(.top, 4)
                        }
                    }
                }
                .padding()
            }

            Divider()

            // --- Footer with Apply & Close ---
            HStack {
                Spacer()
                Button("Apply & Close") {
                    applySettings()
                    // Close the settings window
                    NSApp.keyWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 400, height: 620)
        .onAppear {
            loadHotkeyConfigs()
        }
    }

    // MARK: - Helper views

    /// A labeled section with a title
    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            content()
        }
    }

    /// A slider for adjusting an interval in minutes
    private func intervalSlider(label: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .frame(width: 120, alignment: .leading)
                Slider(value: value, in: range, step: step)
                Text("\(Int(value.wrappedValue)) min")
                    .frame(width: 55, alignment: .trailing)
                    .font(.system(.body, design: .monospaced))
            }
        }
    }

    // MARK: - Hotkey config management

    /// Load hotkey configs from UserDefaults into @State properties
    private func loadHotkeyConfigs() {
        let configs = HotkeyConfig.loadAll()
        hotkeyStood = configs["stood"] ?? HotkeyConfig.defaults["stood"]!
        hotkeySat = configs["sat"] ?? HotkeyConfig.defaults["sat"]!
        hotkeyWater = configs["water"] ?? HotkeyConfig.defaults["water"]!
        hotkeyWalked = configs["walked"] ?? HotkeyConfig.defaults["walked"]!
        hotkeyPauseResume = configs["pauseResume"] ?? HotkeyConfig.defaults["pauseResume"]!
    }

    /// Reset all hotkeys to their default values
    private func resetHotkeysToDefaults() {
        hotkeyStood = HotkeyConfig.defaults["stood"]!
        hotkeySat = HotkeyConfig.defaults["sat"]!
        hotkeyWater = HotkeyConfig.defaults["water"]!
        hotkeyWalked = HotkeyConfig.defaults["walked"]!
        hotkeyPauseResume = HotkeyConfig.defaults["pauseResume"]!
    }

    // MARK: - Apply settings to the timer system

    private func applySettings() {
        // Update debug mode
        TimerCoordinator.shared.debugMode = debugMode

        // Intervals are already saved to UserDefaults via @AppStorage.
        // ReminderCategory reads them automatically. We just need to
        // restart all timers so the new intervals take effect.
        if !TimerCoordinator.shared.isPaused {
            TimerCoordinator.shared.restartAllTimers()
        }

        // Save custom hotkey configs to UserDefaults
        let configs: [String: HotkeyConfig] = [
            "stood": hotkeyStood,
            "sat": hotkeySat,
            "water": hotkeyWater,
            "walked": hotkeyWalked,
            "pauseResume": hotkeyPauseResume,
        ]
        HotkeyConfig.saveAll(configs)

        // Re-register all hotkeys with the new configs
        HotkeyManager.shared.registerHotkeys()

        print("⚙ Settings applied (intervals, hotkeys, position)")
    }

    // MARK: - Launch at login

    private func setLaunchAtLogin(_ enabled: Bool) {
        // macOS 13+ way to register/unregister launch at login
        // This uses SMAppService which handles the login item registration
        do {
            if enabled {
                try SMAppService.mainApp.register()
                print("⚙ Launch at login: enabled")
            } else {
                try SMAppService.mainApp.unregister()
                print("⚙ Launch at login: disabled")
            }
        } catch {
            print("⚠️ Failed to set launch at login: \(error)")
        }
    }
}
