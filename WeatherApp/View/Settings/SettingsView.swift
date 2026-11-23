import SwiftUI

/// The Settings tab (SPEC.md §6, W-06). One column in portrait; two columns in
/// landscape and on iPad so the form doesn't stretch across the whole width (W-18).
///
/// TODO (plan step 8): replace the local `@State` with `SettingsViewModel` / `SettingsStore`
/// so the values are saved and used by the forecast request.
struct SettingsView: View {
    @State private var settings = UserSettings()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    /// iPhone landscape has a compact height; iPad has a regular width.
    private var usesTwoColumns: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    var body: some View {
        NavigationStack {
            Group {
                if usesTwoColumns {
                    HStack(alignment: .top, spacing: 0) {
                        Form {
                            unitsSection
                            displaySection
                        }
                        Form {
                            dataSection
                            aboutSection
                        }
                    }
                } else {
                    Form {
                        unitsSection
                        displaySection
                        dataSection
                        aboutSection
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: - Sections

    private var unitsSection: some View {
        Section("Units") {
            Picker(selection: $settings.temperatureUnit) {
                ForEach(UserSettings.TemperatureUnit.allCases) { unit in
                    Text(unit.title).tag(unit)
                }
            } label: {
                Label("Temperature", systemImage: "thermometer.medium")
            }
            .pickerStyle(.menu)

            Picker(selection: $settings.windSpeedUnit) {
                ForEach(UserSettings.WindSpeedUnit.allCases) { unit in
                    Text(unit.title).tag(unit)
                }
            } label: {
                Label("Wind speed", systemImage: "wind")
            }
            .pickerStyle(.menu)
        }
    }

    private var displaySection: some View {
        Section("Display") {
            Picker(selection: $settings.appearance) {
                ForEach(UserSettings.Appearance.allCases) { appearance in
                    Text(appearance.title).tag(appearance)
                }
            } label: {
                Label("Appearance", systemImage: "circle.lefthalf.filled")
            }
            .pickerStyle(.menu)

            Picker(selection: $settings.timeFormat) {
                ForEach(UserSettings.TimeFormat.allCases) { format in
                    Text(format.title).tag(format)
                }
            } label: {
                Label("Time format", systemImage: "clock")
            }
            .pickerStyle(.menu)
        }
    }

    private var dataSection: some View {
        Section {
            Picker(selection: $settings.refreshInterval) {
                ForEach(UserSettings.RefreshInterval.allCases) { interval in
                    Text(interval.title).tag(interval)
                }
            } label: {
                Label("Refresh when older than", systemImage: "arrow.clockwise")
            }
            .pickerStyle(.menu)
        } header: {
            Text("Data")
        } footer: {
            Text(refreshFooterText)
        }
    }

    private var aboutSection: some View {
        Section("About") {
            LabeledContent("Version", value: appVersion)
            LabeledContent("Forecast", value: "Open-Meteo")
            LabeledContent("Place search", value: "geocode.maps.co")
        }
    }

    // MARK: - Text

    private var refreshFooterText: String {
        if let minutes = settings.refreshInterval.minutes {
            "The forecast is refreshed when you open the app and it is more than \(minutes) minutes old."
        } else {
            "The forecast is only refreshed when you search for a place."
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }
}

#Preview("Portrait") {
    SettingsView()
}

#Preview("Landscape", traits: .landscapeLeft) {
    SettingsView()
}
