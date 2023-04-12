//
//  GeneralSettingsView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/1/23.
//

import SwiftUI

/// A view that implements the `General` settings page
struct GeneralSettingsView: View {
    private let inputWidth: Double = 160
    private let textEditorWidth: Double = 220
    private let textEditorHeight: Double = 30

    @EnvironmentObject
    var updater: SoftwareUpdater

    @AppSettings var settings

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
        SettingsForm {
            Section {
                appearance
                fileIconStyle
                tabBarStyle
            }
            Section {
                showIssues
                showLiveIssues
            }
            Section {
                autoSave
                revealFileOnFocusChangeToggle
                reopenBehavior
                afterWindowsCloseBehaviour
                fileExtensions
            }
            Section {
                projectNavigatorSize
                findNavigatorDetail
                issueNavigatorDetail
            }
            Section {
                openInCodeEditToggle
                shellCommand
                dialogWarnings

            }
            Section {
                updateChecker
                autoUpdateToggle
                prereleaseToggle
            }
        }
    }
}

/// The extension of the view with all the preferences
private extension GeneralSettingsView {
    // MARK: - Sections

    var appearance: some View {
        Picker("Appearance", selection: $settings.general.appAppearance) {
            Text("System")
                .tag(SettingsData.Appearances.system)
            Divider()
            Text("Light")
                .tag(SettingsData.Appearances.light)
            Text("Dark")
                .tag(SettingsData.Appearances.dark)
        }
        .onChange(of: settings.general.appAppearance) { tag in
            tag.applyAppearance()
        }
    }

    // TODO: Implement reflecting Show Issues preference and remove disabled modifier
    var showIssues: some View {
        Picker("Show Issues", selection: $settings.general.showIssues) {
            Text("Show Inline")
                .tag(SettingsData.Issues.inline)
            Text("Show Minimized")
                .tag(SettingsData.Issues.minimized)
        }
    }

    var showLiveIssues: some View {
        Toggle("Show Live Issues", isOn: $settings.general.showLiveIssues)
    }

    var fileExtensions: some View {
        Group {
            Picker("File Extensions", selection: $settings.general.fileExtensionsVisibility) {
                Text("Hide all")
                    .tag(SettingsData.FileExtensionsVisibility.hideAll)
                Text("Show all")
                    .tag(SettingsData.FileExtensionsVisibility.showAll)
                Divider()
                Text("Show only")
                    .tag(SettingsData.FileExtensionsVisibility.showOnly)
                Text("Hide only")
                    .tag(SettingsData.FileExtensionsVisibility.hideOnly)
            }
            if case .showOnly = settings.general.fileExtensionsVisibility {
                SettingsTextEditor(text: $settings.general.shownFileExtensions.string)
                    .frame(height: textEditorHeight)
            }
            if case .hideOnly = settings.general.fileExtensionsVisibility {
                SettingsTextEditor(text: $settings.general.hiddenFileExtensions.string)
                .frame(height: textEditorHeight)
            }
        }
    }

    var fileIconStyle: some View {
        Picker("File Icon Style", selection: $settings.general.fileIconStyle) {
            Text("Color")
                .tag(SettingsData.FileIconStyle.color)
            Text("Monochrome")
                .tag(SettingsData.FileIconStyle.monochrome)
        }
        .pickerStyle(.radioGroup)
    }

    var tabBarStyle: some View {
        Picker("Tab Bar Style", selection: $settings.general.tabBarStyle) {
            Text("Xcode")
                .tag(SettingsData.TabBarStyle.xcode)
            Text("Native")
                .tag(SettingsData.TabBarStyle.native)
        }
        .pickerStyle(.radioGroup)
    }

    var reopenBehavior: some View {
        Picker("Reopen Behavior", selection: $settings.general.reopenBehavior) {
            Text("Welcome Screen")
                .tag(SettingsData.ReopenBehavior.welcome)
            Divider()
            Text("Open Panel")
                .tag(SettingsData.ReopenBehavior.openPanel)
            Text("New Document")
                .tag(SettingsData.ReopenBehavior.newDocument)
        }
    }

    var afterWindowsCloseBehaviour: some View {
        Picker(
            "After the last window is closed",
            selection: $settings.general.reopenWindowAfterClose
        ) {
            Text("Do nothing")
                .tag(SettingsData.ReopenWindowBehavior.doNothing)
            Divider()
            Text("Show Welcome Window")
                .tag(SettingsData.ReopenWindowBehavior.showWelcomeWindow)
            Text("Quit")
                .tag(SettingsData.ReopenWindowBehavior.quit)
        }
    }

    var projectNavigatorSize: some View {
        Picker("Project Navigator Size", selection: $settings.general.projectNavigatorSize) {
            Text("Small")
                .tag(SettingsData.ProjectNavigatorSize.small)
            Text("Medium")
                .tag(SettingsData.ProjectNavigatorSize.medium)
            Text("Large")
                .tag(SettingsData.ProjectNavigatorSize.large)
        }
    }

    var findNavigatorDetail: some View {
        Picker("Find Navigator Detail", selection: $settings.general.findNavigatorDetail) {
            ForEach(SettingsData.NavigatorDetail.allCases, id: \.self) { tag in
                Text(tag.label).tag(tag)
            }
        }
    }

    // TODO: Implement reflecting Issue Navigator Detail preference and remove disabled modifier
    var issueNavigatorDetail: some View {
        Picker("Issue Navigator Detail", selection: $settings.general.issueNavigatorDetail) {
            ForEach(SettingsData.NavigatorDetail.allCases, id: \.self) { tag in
                Text(tag.label).tag(tag)
            }
        }
        .disabled(true)
    }

    // TODO: Implement reset for Don't Ask Me warnings Button and remove disabled modifier
    var dialogWarnings: some View {
        LabeledContent("Dialog Warnings") {
            Button(action: {
            }, label: {
                Text("Reset \"Don't Ask Me\" Warnings")
            })
            .buttonStyle(.bordered)
        }
        .disabled(true)
    }

    var shellCommand: some View {
        LabeledContent("Shell Command") {
            Button(action: installShellCommand, label: {
                Text("Install 'codeedit' command")
            })
//            .disabled(true)
            .buttonStyle(.bordered)
        }
    }

    func installShellCommand() {
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
    }

    var updateChecker: some View {
        Section {
            LabeledContent {
                Button("Check Now") {
                    updater.checkForUpdates()
                }
            } label: {
                Text("Check for updates")
                Text("Last checked: \(lastUpdatedString)")

            }
        }
    }

    var autoUpdateToggle: some View {
        Toggle("Automatically check for app updates", isOn: $updater.automaticallyChecksForUpdates)
    }

    var prereleaseToggle: some View {
        Toggle("Include pre-release versions", isOn: $updater.includePrereleaseVersions)
    }

    var autoSave: some View {
        Toggle(
            "Automatically save changes to disk",
            isOn: $settings.general.isAutoSaveOn
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
        Toggle("Show “Open With CodeEdit” option in Finder", isOn: $openInCodeEdit)
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
        Toggle("Automatically reveal in project navigator", isOn: $settings.general.revealFileOnFocusChange)
    }

    // MARK: - Formatters

    private static let formatter = configure(DateFormatter()) {
        $0.dateStyle = .medium
        $0.timeStyle = .medium
    }
}
