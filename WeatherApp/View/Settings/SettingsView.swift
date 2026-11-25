import SwiftUI

/// The Settings tab (SPEC.md §6, W-06). One column in portrait; two columns in
/// landscape and on iPad so the form doesn't stretch across the whole width (W-18).
struct SettingsView: View {
    /// Saves every change straight away (W-06).
    @Bindable var viewModel: SettingsViewModel
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
            optionPicker("Temperature", systemImage: "thermometer.medium", selection: $viewModel.settings.temperatureUnit)

            optionPicker("Wind speed", systemImage: "wind", selection: $viewModel.settings.windSpeedUnit)
        }
    }

    private var displaySection: some View {
        Section("Display") {
            optionPicker("Appearance", systemImage: "circle.lefthalf.filled", selection: $viewModel.settings.appearance)

            optionPicker("Time format", systemImage: "clock", selection: $viewModel.settings.timeFormat)
        }
    }

    private var dataSection: some View {
        Section {
            optionPicker("Refresh when older than", systemImage: "arrow.clockwise", selection: $viewModel.settings.refreshInterval)
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

    /// A menu picker with every case of a setting, e.g. °C / °F. All setting enums have a `title`.
    private func optionPicker<Option: CaseIterable & Identifiable & Hashable & SettingOption>(
        _ label: String,
        systemImage: String,
        selection: Binding<Option>
    ) -> some View where Option.AllCases: RandomAccessCollection {
        Picker(selection: selection) {
            ForEach(Option.allCases) { option in
                Text(option.title).tag(option)
            }
        } label: {
            Label(label, systemImage: systemImage)
        }
        .pickerStyle(.menu)
    }

    // MARK: - Text

    private var refreshFooterText: String {
        if let minutes = viewModel.settings.refreshInterval.minutes {
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
    SettingsView(viewModel: .preview)
}

#Preview("Landscape", traits: .landscapeLeft) {
    SettingsView(viewModel: .preview)
}

private extension SettingsViewModel {
    /// Its own throwaway `UserDefaults`, so previews never touch the app's saved settings.
    static var preview: SettingsViewModel {
        SettingsViewModel(store: SettingsStore(defaults: UserDefaults(suiteName: "preview-settings") ?? .standard))
    }
}
