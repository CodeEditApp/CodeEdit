//
//  GeneralPreferencesView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

/// A view that implements the `General` preference section
struct GeneralPreferencesView: View {
    private let inputWidth: Double = 160
    private let textEditorWidth: Double = 220
    private let textEditorHeight: Double = 30

    @EnvironmentObject
    var updater: SoftwareUpdater

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var openInCodeEdit: Bool = true

    init() {
        guard let defaults = UserDefaults.init(
            suiteName: "austincondiff.CodeEdit.shared"
        ) else {
            print("Failed to get/init shared defaults")
            return
        }

        self.openInCodeEdit = defaults.bool(forKey: "enableOpenInCE")
    }

    var body: some View {
        PreferencesContent {
            appearanceSection
            showIssuesSection
            fileExtensionsSection
            fileIconStyleSection
            tabBarStyleSection
            reopenBehaviorSection
            projectNavigatorSizeSection
            findNavigatorDetailSection
            Group {
                issueNavigatorDetailSection
                dialogWarningsSection
            }
            Group {
                openInCodeEditToggle
                revealFileOnFocusChangeToggle
                shellCommandSection
                autoSaveSection
                updaterSection
            }
        }
    }
}

private extension GeneralPreferencesView {
    var appearanceSection: some View {
        PreferencesSection("Appearance") {
            Picker("Appearance", selection: $prefs.preferences.general.appAppearance) {
                Text("System")
                    .tag(AppPreferences.Appearances.system)
                Divider()
                Text("Light")
                    .tag(AppPreferences.Appearances.light)
                Text("Dark")
                    .tag(AppPreferences.Appearances.dark)
            }
            .onChange(of: prefs.preferences.general.appAppearance) { tag in
                tag.applyAppearance()
            }
            .frame(width: inputWidth)
        }
    }

    // TODO: Implement reflecting Show Issues preference and remove disabled modifier
    var showIssuesSection: some View {
        PreferencesSection("Show Issues", hideLabels: false) {
            Picker("Show Issues", selection: $prefs.preferences.general.showIssues) {
                Text("Show Inline")
                    .tag(AppPreferences.Issues.inline)
                Text("Show Minimized")
                    .tag(AppPreferences.Issues.minimized)
            }
            .labelsHidden()
            .frame(width: inputWidth)

            Toggle("Show Live Issues", isOn: $prefs.preferences.general.showLiveIssues)
                .toggleStyle(.checkbox)
        }
        .disabled(true)
    }

    var fileExtensionsSection: some View {
        PreferencesSection("File Extensions") {
            Picker("File Extensions:", selection: $prefs.preferences.general.fileExtensionsVisibility) {
                Text("Hide all")
                    .tag(AppPreferences.FileExtensionsVisibility.hideAll)
                Text("Show all")
                    .tag(AppPreferences.FileExtensionsVisibility.showAll)
                Divider()
                Text("Show only")
                    .tag(AppPreferences.FileExtensionsVisibility.showOnly)
                Text("Hide only")
                    .tag(AppPreferences.FileExtensionsVisibility.hideOnly)
            }
            .frame(width: inputWidth)
            if case .showOnly = prefs.preferences.general.fileExtensionsVisibility {
                SettingsTextEditor(text: $prefs.preferences.general.shownFileExtensions.string)
                    .frame(width: textEditorWidth)
                    .frame(height: textEditorHeight)
            }
            if case .hideOnly = prefs.preferences.general.fileExtensionsVisibility {
                SettingsTextEditor(text: $prefs.preferences.general.hiddenFileExtensions.string)
                .frame(width: textEditorWidth)
                .frame(height: textEditorHeight)
            }
        }
    }

    var fileIconStyleSection: some View {
        PreferencesSection("File Icon Style") {
            Picker("File Icon Style:", selection: $prefs.preferences.general.fileIconStyle) {
                Text("Color")
                    .tag(AppPreferences.FileIconStyle.color)
                Text("Monochrome")
                    .tag(AppPreferences.FileIconStyle.monochrome)
            }
            .pickerStyle(.radioGroup)
        }
    }

    var tabBarStyleSection: some View {
        PreferencesSection("Tab Bar Style") {
            Picker("Tab Bar Style:", selection: $prefs.preferences.general.tabBarStyle) {
                Text("Xcode")
                    .tag(AppPreferences.TabBarStyle.xcode)
                Text("Native")
                    .tag(AppPreferences.TabBarStyle.native)
            }
            .pickerStyle(.radioGroup)
        }
    }

    var reopenBehaviorSection: some View {
        PreferencesSection("Reopen Behavior") {
            Picker("Reopen Behavior:", selection: $prefs.preferences.general.reopenBehavior) {
                Text("Welcome Screen")
                    .tag(AppPreferences.ReopenBehavior.welcome)
                Divider()
                Text("Open Panel")
                    .tag(AppPreferences.ReopenBehavior.openPanel)
                Text("New Document")
                    .tag(AppPreferences.ReopenBehavior.newDocument)
            }
            .frame(width: inputWidth)
        }
    }

    var projectNavigatorSizeSection: some View {
        PreferencesSection("Project Navigator Size") {
            Picker("Project Navigator Size", selection: $prefs.preferences.general.projectNavigatorSize) {
                Text("Small")
                    .tag(AppPreferences.ProjectNavigatorSize.small)
                Text("Medium")
                    .tag(AppPreferences.ProjectNavigatorSize.medium)
                Text("Large")
                    .tag(AppPreferences.ProjectNavigatorSize.large)
            }
            .frame(width: inputWidth)
        }
    }

    var findNavigatorDetailSection: some View {
        PreferencesSection("Find Navigator Detail") {
            Picker("Find Navigator Detail", selection: $prefs.preferences.general.findNavigatorDetail) {
                ForEach(AppPreferences.NavigatorDetail.allCases, id: \.self) { tag in
                    Text(tag.label).tag(tag)
                }
            }
            .frame(width: inputWidth)
        }
    }

    // TODO: Implement reflecting Issue Navigator Detail preference and remove disabled modifier
    var issueNavigatorDetailSection: some View {
        PreferencesSection("Issue Navigator Detail") {
            Picker("Issue Navigator Detail", selection: $prefs.preferences.general.issueNavigatorDetail) {
                ForEach(AppPreferences.NavigatorDetail.allCases, id: \.self) { tag in
                    Text(tag.label).tag(tag)
                }
            }
            .frame(width: inputWidth)
        }
        .disabled(true)
    }

    // TODO: Implement reset for Don't Ask Me warnings Button and remove disabled modifier
    var dialogWarningsSection: some View {
        PreferencesSection("Dialog Warnings", align: .center) {
            Button(action: {
            }, label: {
                Text("Reset \"Don't Ask Me\" Warnings")
                    .padding(.horizontal, 10)
            })
            .buttonStyle(.bordered)
        }
        .disabled(true)
    }

    var shellCommandSection: some View {
        PreferencesSection("Shell Command", align: .center) {
            Button(action: {
                do {
                    let url = Bundle.main.url(forResource: "codeedit", withExtension: nil, subdirectory: "Resources")
                    let destination = "/usr/local/bin/codeedit"

                    if FileManager.default.fileExists(atPath: destination) {
                        try FileManager.default.removeItem(atPath: destination)
                    }

                    guard let shellUrl = url?.path else {
                        print("Failed to get URL to shell command")
                        return
                    }

                    NSWorkspace.shared.requestAuthorization(to: .createSymbolicLink) { auth, error in
                        guard let auth = auth, error == nil else {
                            fallbackShellInstallation(commandPath: shellUrl, destinationPath: destination)
                            return
                        }

                        do {
                            try FileManager(authorization: auth).createSymbolicLink(
                                atPath: destination, withDestinationPath: shellUrl
                            )
                        } catch {
                            fallbackShellInstallation(commandPath: shellUrl, destinationPath: destination)
                        }
                    }
                } catch {
                    print(error)
                }
            }, label: {
                Text("Install 'codeedit' command")
                    .padding(.horizontal, 10)
            })
            .buttonStyle(.bordered)
        }
    }

    var updaterSection: some View {
        PreferencesSection("Software Updates", hideLabels: false) {
            VStack(alignment: .leading) {
                Toggle("Automatically check for app updates", isOn: $updater.automaticallyChecksForUpdates)

                Toggle("Include pre-release versions", isOn: $updater.includePrereleaseVersions)

                Button("Check Now") {
                    updater.checkForUpdates()
                }

                Text("Last checked: \(lastUpdatedString)")
                    .font(.footnote)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var lastUpdatedString: String {
        if let lastUpdatedDate = updater.lastUpdateCheckDate {
            return Self.formatter.string(from: lastUpdatedDate)
        } else {
            return "Never"
        }
    }

    private static let formatter = configure(DateFormatter()) {
        $0.dateStyle = .medium
        $0.timeStyle = .medium
    }

    var autoSaveSection: some View {
        PreferencesSection("Auto Save Behavior", hideLabels: false) {
            Toggle("Automatically save changes to disk",
                   isOn: $prefs.preferences.general.isAutoSaveOn)
            .toggleStyle(.checkbox)
        }
    }

    func fallbackShellInstallation(commandPath: String, destinationPath: String) {
        let cmd = [
            "osascript",
            "-e",
            "\"do shell script \\\"mkdir -p /usr/local/bin && ln -sf \'\(commandPath)\' \'\(destinationPath)\'\\\"\"",
            "with administrator privileges"
        ]

        let cmdStr = cmd.joined(separator: " ")

        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", cmdStr]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.standardInput = nil

        do {
            try task.run()
        } catch {
            print(error)
        }
    }

    var openInCodeEditToggle: some View {
        PreferencesSection("Finder Context Menu", hideLabels: false) {
            Toggle("Show “Open With CodeEdit” option", isOn: $openInCodeEdit)
                .toggleStyle(.checkbox)
                .onChange(of: openInCodeEdit) { newValue in
                    guard let defaults = UserDefaults.init(
                        suiteName: "austincondiff.CodeEdit.shared"
                    ) else {
                        print("Failed to get/init shared defaults")
                        return
                    }

                    defaults.set(newValue, forKey: "enableOpenInCE")
                }
        }
    }

    var revealFileOnFocusChangeToggle: some View {
        PreferencesSection("Project Navigator Behavior", hideLabels: false) {
            Toggle("Automatically Show Active File", isOn: $prefs.preferences.general.revealFileOnFocusChange)
                .toggleStyle(.checkbox)
        }
    }
}

func configure<Subject>(_ subject: Subject, configuration: (inout Subject) -> Void) -> Subject {
    var copy = subject
    configuration(&copy)
    return copy
}
