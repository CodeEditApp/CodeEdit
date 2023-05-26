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

    @AppSettings(\.theme.matchAppearance) private var matchAppearance
    @AppSettings(\.terminal.darkAppearance) private var darkAppearance
    @AppSettings(\.theme.useThemeBackground) private var useThemeBackground

    @StateObject
    private var themeModel: ThemeModel = .shared

    @State
    private var searchText = ""

    /// Returns the `background` color of the selected theme
    private var backgroundColor: NSColor {
        if let selectedTheme = matchAppearance && darkAppearance
            ? themeModel.selectedDarkTheme
            : themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.background.swiftColor)
        }
        return .windowBackgroundColor
    }

    var body: some View {
        switch model.selectedTab {
        case .output(let extensionInfo):
            ExtensionOutputView(ext: extensionInfo)
        default:
            if let url = workspace.workspaceFileManager?.folderUrl {
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
                        Button {
                            // TODO: clear logs
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.icon)
                        Divider()
                        HStack(alignment: .center, spacing: 3.5) {
                            Button {
                                // TODO: split terminal
                            } label: {
                                Image(systemName: "square.split.2x1")
                            }
                            .buttonStyle(.icon)
                            Button {
                                model.isMaximized.toggle()
                            } label: {
                                Image(systemName: "arrowtriangle.up.square")
                            }
                            .buttonStyle(.icon(isActive: model.isMaximized))
                        }
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 8)
                    .frame(maxHeight: 28)
                }
                .background {
                    if useThemeBackground {
                        Color(nsColor: backgroundColor)
                    } else {
                        if colorScheme == .dark {
                            EffectView(.underPageBackground)
                        } else {
                            EffectView(.contentBackground)
                        }
                    }
                }
                .colorScheme(
                    matchAppearance && darkAppearance
                    ? themeModel.selectedDarkTheme?.appearance == .dark ? .dark : .light
                    : themeModel.selectedTheme?.appearance == .dark ? .dark : .light
                )
            }
        }
    }
}
