//
//  GeneralPreferencesView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

/// A view that implements the `General` preference section
public struct GeneralPreferencesView: View {

    private let inputWidth: Double = 160

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var openInCodeEdit: Bool = true

    public init() {
        guard let defaults = UserDefaults.init(
            suiteName: "austincondiff.CodeEdit.shared"
        ) else {
            print("Failed to get/init shared defaults")
            return
        }

        self.openInCodeEdit = defaults.bool(forKey: "enableOpenInCE")
    }

    public var body: some View {
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
            openInCodeEditToggle
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

    // TODO: Implement reflecting File Extensions preference and remove disabled modifier
    var fileExtensionsSection: some View {
        PreferencesSection("File Extensions") {
            Picker("File Extensions:", selection: $prefs.preferences.general.fileExtensions) {
                Text("Hide all")
                    .tag(AppPreferences.FileExtensions.hideAll)
                Text("Show all")
                    .tag(AppPreferences.FileExtensions.showAll)
                Divider()
                Text("Show only")
                    .tag(AppPreferences.FileExtensions.showOnly)
            }
            .frame(width: inputWidth)
        }
        .disabled(true)
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
}
