//
//  StatusBarDrawer.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct StatusBarDrawer: View {
    @EnvironmentObject
    private var model: StatusBarViewModel

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @Environment(\.colorScheme)
    private var colorScheme

    @State
    private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            TerminalEmulatorView(url: model.workspaceURL)
                .background {
                    if colorScheme == .dark {
                        if prefs.preferences.theme.selectedTheme == prefs.preferences.theme.selectedLightTheme {
                            Color.white
                        } else {
                            EffectView(.underPageBackground)
                        }
                    } else {
                        if prefs.preferences.theme.selectedTheme == prefs.preferences.theme.selectedDarkTheme {
                            Color.black
                        } else {
                            EffectView(.contentBackground)
                        }
                    }
                }
            HStack(alignment: .center, spacing: 10) {
                FilterTextField(title: "Filter", text: $searchText)
                    .frame(maxWidth: 300)
                Spacer()
                StatusBarClearButton()
                Divider()
                StatusBarSplitTerminalButton()
                StatusBarMaximizeButton()
            }
            .padding(10)
            .frame(maxHeight: 29)
            .background(.bar)
        }
        
    }
}
