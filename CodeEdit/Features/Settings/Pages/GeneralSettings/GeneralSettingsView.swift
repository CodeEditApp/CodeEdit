//
//  GeneralSettingsView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/1/23.
//

import SwiftUI

/// A view that implements the `General` preference section
struct GeneralSettingsView: View {
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
        Form {
            Section {
                appearanceSection
                fileIconStyleSection
                tabBarStyleSection
            }
            Section {
                showIssuesSection
            }
            Section {
                fileExtensionsSection
                Group {
                    reopenBehaviorSection
                    reopenAfterWindowCloseBehaviourSection
                }
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
                }
            }
            updaterSection
        }
        .formStyle(.grouped)
    }
}

/// The extension of the view with all the preferences
private extension GeneralSettingsView {
    // MARK: - Sections

    var appearanceSection: some View {
        Group {
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
        }
    }

    // TODO: Implement reflecting Show Issues preference and remove disabled modifier
    var showIssuesSection: some View {
        Group {
            Picker("Show Issues", selection: $prefs.preferences.general.showIssues) {
                Text("Show Inline")
                    .tag(AppPreferences.Issues.inline)
                Text("Show Minimized")
                    .tag(AppPreferences.Issues.minimized)
            }
            Toggle("Show Live Issues", isOn: $prefs.preferences.general.showLiveIssues)
        }
    }

    var fileExtensionsSection: some View {
        Group {
            Picker("File Extensions", selection: $prefs.preferences.general.fileExtensionsVisibility) {
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
            if case .showOnly = prefs.preferences.general.fileExtensionsVisibility {
                SettingsTextEditor(text: $prefs.preferences.general.shownFileExtensions.string)
//                    .frame(width: textEditorWidth)
                    .frame(height: textEditorHeight)
            }
            if case .hideOnly = prefs.preferences.general.fileExtensionsVisibility {
                SettingsTextEditor(text: $prefs.preferences.general.hiddenFileExtensions.string)
//                .frame(width: textEditorWidth)
                .frame(height: textEditorHeight)
            }
        }
    }

    var fileIconStyleSection: some View {
        Group {
            Picker("File Icon Style", selection: $prefs.preferences.general.fileIconStyle) {
                Text("Color")
                    .tag(AppPreferences.FileIconStyle.color)
                Text("Monochrome")
                    .tag(AppPreferences.FileIconStyle.monochrome)
            }
            .pickerStyle(.radioGroup)
        }
    }

    var tabBarStyleSection: some View {
        Group {
            Picker("Tab Bar Style", selection: $prefs.preferences.general.tabBarStyle) {
                Text("Xcode")
                    .tag(AppPreferences.TabBarStyle.xcode)
                Text("Native")
                    .tag(AppPreferences.TabBarStyle.native)
            }
            .pickerStyle(.radioGroup)
        }
    }

    var reopenBehaviorSection: some View {
        Group {
            Picker("Reopen Behavior", selection: $prefs.preferences.general.reopenBehavior) {
                Text("Welcome Screen")
                    .tag(AppPreferences.ReopenBehavior.welcome)
                Divider()
                Text("Open Panel")
                    .tag(AppPreferences.ReopenBehavior.openPanel)
                Text("New Document")
                    .tag(AppPreferences.ReopenBehavior.newDocument)
            }
        }
    }

    var reopenAfterWindowCloseBehaviourSection: some View {
        Group {
            Picker(
                "After the last window is closed",
                selection: $prefs.preferences.general.reopenWindowAfterClose
            ) {
                Text("Do nothing")
                    .tag(AppPreferences.ReopenWindowBehavior.doNothing)
                Divider()
                Text("Show Welcome Window")
                    .tag(AppPreferences.ReopenWindowBehavior.showWelcomeWindow)
                Text("Quit")
                    .tag(AppPreferences.ReopenWindowBehavior.quit)
            }
        }
    }

    var projectNavigatorSizeSection: some View {
        Group {
            Picker("Project Navigator Size", selection: $prefs.preferences.general.projectNavigatorSize) {
                Text("Small")
                    .tag(AppPreferences.ProjectNavigatorSize.small)
                Text("Medium")
                    .tag(AppPreferences.ProjectNavigatorSize.medium)
                Text("Large")
                    .tag(AppPreferences.ProjectNavigatorSize.large)
            }
        }
    }

    var findNavigatorDetailSection: some View {
        Group {
            Picker("Find Navigator Detail", selection: $prefs.preferences.general.findNavigatorDetail) {
                ForEach(AppPreferences.NavigatorDetail.allCases, id: \.self) { tag in
                    Text(tag.label).tag(tag)
                }
            }
        }
    }

    // TODO: Implement reflecting Issue Navigator Detail preference and remove disabled modifier
    var issueNavigatorDetailSection: some View {
        Group {
            Picker("Issue Navigator Detail", selection: $prefs.preferences.general.issueNavigatorDetail) {
                ForEach(AppPreferences.NavigatorDetail.allCases, id: \.self) { tag in
                    Text(tag.label).tag(tag)
                }
            }
        }
        .disabled(true)
    }

    // TODO: Implement reset for Don't Ask Me warnings Button and remove disabled modifier
    var dialogWarningsSection: some View {
        LabeledContent("Dialog Warnings") {
            Button(action: {
            }, label: {
                Text("Reset \"Don't Ask Me\" Warnings")
            })
            .buttonStyle(.bordered)
        }
        .disabled(true)
    }

    var shellCommandSection: some View {
        LabeledContent("Shell Command") {
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
                        guard let auth, error == nil else {
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
            })
            .disabled(true)
            .buttonStyle(.bordered)
        }
    }

    var updaterSection: some View {
        Section {
            LabeledContent {
                Button("Check Now") {
                    updater.checkForUpdates()
                }
            } label: {
                Text("Check for updates")
                Text("Last checked: \(lastUpdatedString)")

            }

            Toggle("Automatically check for app updates", isOn: $updater.automaticallyChecksForUpdates)

            Toggle("Include pre-release versions", isOn: $updater.includePrereleaseVersions)
        }
    }

    var autoSaveSection: some View {
        Toggle(
            "Automatically save changes to disk",
            isOn: $prefs.preferences.general.isAutoSaveOn
        )
    }

    // MARK: - Preference Views

    private var lastUpdatedString: String {
        if let lastUpdatedDate = updater.lastUpdateCheckDate {
            return Self.formatter.string(from: lastUpdatedDate)
        } else {
            return "Never"
        }
    }

    private static func configure<Subject>(_ subject: Subject, configuration: (inout Subject) -> Void) -> Subject {
        var copy = subject
        configuration(&copy)
        return copy
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
        // Finder Context Menu
            Toggle("Show “Open With CodeEdit” option", isOn: $openInCodeEdit)
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

    var revealFileOnFocusChangeToggle: some View {
        // Project Navigator Behavior
        Toggle("Automatically Show Active File", isOn: $prefs.preferences.general.revealFileOnFocusChange)
    }

    // MARK: - Formatters

    private static let formatter = configure(DateFormatter()) {
        $0.dateStyle = .medium
        $0.timeStyle = .medium
    }
}