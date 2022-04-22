//
//  GeneralPreferencesView.swift
//  
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

/// A view that implements the `General` preference section
public struct GeneralPreferencesView: View {

    private let inputWidth: Double = 160

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    public init() {}

    public var body: some View {
        PreferencesContent {
            PreferencesSection("Appearance") {
                Picker("Appearance:", selection: $prefs.preferences.general.appAppearance) {
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
            PreferencesSection("File Icon Style") {
                Picker("File Icon Style:", selection: $prefs.preferences.general.fileIconStyle) {
                    Text("Color")
                        .tag(AppPreferences.FileIconStyle.color)
                    Text("Monochrome")
                        .tag(AppPreferences.FileIconStyle.monochrome)
                }
                .pickerStyle(.radioGroup)
            }
            PreferencesSection("Tab Bar Style") {
                Picker("Tab Bar Style:", selection: $prefs.preferences.general.tabBarStyle) {
                    Text("Xcode")
                        .tag(AppPreferences.TabBarStyle.xcode)
                    Text("Native")
                        .tag(AppPreferences.TabBarStyle.native)
                }
                .pickerStyle(.radioGroup)
            }
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
    }
}
