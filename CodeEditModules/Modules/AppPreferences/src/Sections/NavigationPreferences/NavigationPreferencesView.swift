//
//  GeneralPreferencesView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Aaryan Kothari on 04.10.22.
//

import SwiftUI
import CodeEditUI

/// A view that implements the `Navigation` preference section
public struct NavigationPreferencesView: View {

    private let inputWidth: Double = 200

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
            Group {
                activationSection
                fullScreenSection
                commandClickSection
                optionClickSection
                controlClicksSection
                spacing
            }
            Group {
                navigationStyleSection
                navigationSection
                optionalNavigationSection
                doubleClickNavigationSection
                clicksSection
            }
        }
    }
}

private extension NavigationPreferencesView {

    var activationSection: some View {
        PreferencesSection("Activation", hideLabels: false) {
            Toggle("When a window tab or window opens, make it active", isOn: $prefs.preferences.navigation.activation)
                .toggleStyle(.checkbox)
        }
    }

    var fullScreenSection: some View {
        PreferencesSection("Full Screen", hideLabels: false) {
            Toggle("Use window tabs instead of windows", isOn: $prefs.preferences.navigation.fullScreen)
                .toggleStyle(.checkbox)
        }
    }

    var commandClickSection: some View {
        PreferencesSection("Command-click on Code") {
            Picker("Command-click on Code", selection: $prefs.preferences.navigation.commandClick) {
                ForEach(AppPreferences.CommandClick.allCases, id: \.self) { pref in
                    Text(pref.label).tag(pref)
                }
            }
            .frame(width: inputWidth)
        }
    }

    var optionClickSection: some View {
        PreferencesSection("Option-click on Code") {
            Picker("Option-click on Code", selection: $prefs.preferences.navigation.optionClick) {
                ForEach(AppPreferences.OptionClick.allCases, id: \.self) { pref in
                    Text(pref.label).tag(pref)
                }
            }
            .frame(width: inputWidth)
        }
    }

    var spacing: some View {
        Spacer().frame(height: 30)
    }

    var controlClicksSection: some View {
        VStack(spacing: -5) {
            PreferencesSection("Command-Control-click") {
                Text("Jumps to Definition")
            }
            PreferencesSection("Option-Control-click") {
                Text("Shows SwiftUI Inspector")
            }
        }
        .font(.caption)
    }

    var navigationStyleSection: some View {
        PreferencesSection("Navigation Style") {
            Picker("Navigation Style", selection: $prefs.preferences.navigation.navigationStyle) {
                ForEach(AppPreferences.NavigationStyle.allCases, id: \.self) { pref in
                    Text(pref.label).tag(pref)
                }
            }
            .frame(width: inputWidth)
        }
    }

    var navigationSection: some View {
        PreferencesSection("Navigation") {
            Picker("Navigation", selection: $prefs.preferences.navigation.navigation) {
                ForEach(AppPreferences.Navigation.allCases, id: \.self) { pref in
                    Text(pref.label).tag(pref)
                }
            }
            .frame(width: inputWidth)
        }
    }

    var optionalNavigationSection: some View {
        PreferencesSection("Optional Navigation") {
            Picker("Optional Navigation", selection: $prefs.preferences.navigation.optionalNavigation) {
                ForEach(AppPreferences.OptionalNavigation.allCases, id: \.self) { pref in
                    Text(pref.label).tag(pref)
                }
            }
            .frame(width: inputWidth)
        }
    }

    var doubleClickNavigationSection: some View {
        PreferencesSection("Double-click Navigation") {
            Picker("Double-click Navigation", selection: $prefs.preferences.navigation.doubleClickNavigation) {
                ForEach(AppPreferences.DoubleClickNavigation.allCases, id: \.self) { pref in
                    Text(pref.label).tag(pref)
                }
            }
            .frame(width: inputWidth)
        }
    }

    var clicksSection: some View {
        VStack(spacing: -5) {
            PreferencesSection("Click") {
                Text("Shows preview in focused editor")
            }
            PreferencesSection("Option-click") {
                Text("Shows preview in next editor")
            }
            PreferencesSection("Option-Shift-click") {
                Text("Displays destination chooser")
            }
            PreferencesSection("Double-click") {
                Text("Opens tab in focused editor")
            }
        }
        .font(.caption)
    }
}
