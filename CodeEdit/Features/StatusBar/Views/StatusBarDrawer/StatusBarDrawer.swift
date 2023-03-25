//
//  StatusBarDrawer.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

struct StatusBarDrawer: View {
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject
    private var model: StatusBarViewModel

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @StateObject
    private var themeModel: ThemeModel = .shared

    @State
    private var searchText = ""

    /// Returns the `background` color of the selected theme
    private var backgroundColor: NSColor {
        if let selectedTheme = themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.background.swiftColor)
        }
        return .windowBackgroundColor
    }

    var body: some View {
        if let url = workspace.workspaceClient?.folderURL() {
            VStack(spacing: 0) {
                TerminalEmulatorView(url: url)
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                    .contentShape(Rectangle())
                HStack(alignment: .center, spacing: 6.5) {
                    FilterTextField(title: "Filter", text: $searchText)
                        .frame(maxWidth: 175)
                        .padding(.leading, -2)
                    Spacer()
                    StatusBarIcon(icon: Image(systemName: "trash")) {
                        // clear logs
                    }
                    Divider()
                    HStack(alignment: .center, spacing: 3.5) {
                        StatusBarIcon(icon: Image(systemName: "square.split.2x1")) {
                            // split terminal
                        }
                        StatusBarIcon(icon: Image(systemName: "arrowtriangle.up.square"), active: model.isMaximized) {
                            model.isMaximized.toggle()
                        }
                    }
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 8)
                .frame(maxHeight: 28)
            }
            .background(Color(nsColor: backgroundColor))
        }
    }
}
