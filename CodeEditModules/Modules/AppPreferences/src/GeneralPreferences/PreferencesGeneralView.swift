//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI
import Preferences

public struct PreferencesGeneralView: View {

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    public init() {}

    public var body: some View {
        Form {
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
            .fixedSize()

            Picker("File Icon Style:", selection: $prefs.preferences.general.fileIconStyle) {
                Text("Color")
                    .tag(AppPreferences.FileIconStyle.color)
                Text("Monochrome")
                    .tag(AppPreferences.FileIconStyle.monochrome)
            }
            .pickerStyle(.radioGroup)

            Picker("Reopen Behavior:", selection: $prefs.preferences.general.reopenBehavior) {
                Text("Welcome Screen")
                    .tag(AppPreferences.ReopenBehavior.welcome)
                Divider()
                Text("Open Panel")
                    .tag(AppPreferences.ReopenBehavior.openPanel)
                Text("New Document")
                    .tag(AppPreferences.ReopenBehavior.newDocument)
            }
            .fixedSize()
        }
        .frame(width: 844)
        .padding(30)
    }
}
