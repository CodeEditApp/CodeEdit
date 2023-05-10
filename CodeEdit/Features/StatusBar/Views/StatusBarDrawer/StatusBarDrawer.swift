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
        if let url = workspace.workspaceFileManager?.folderUrl {
            ZStack(alignment: .bottomLeading) {
                SplitView(axis: .horizontal) {
                    List(selection: $model.debuggerTabSelection) {
                        Label("Terminal", systemImage: "terminal")
                            .tag(StatusBarTabType.terminal)
                        Label("Output", systemImage: "list.bullet.indent")
                            .tag(StatusBarTabType.output)
                        Label("Debugger", systemImage: "ladybug")
                            .tag(StatusBarTabType.debugger)
                    }
                    .collapsable()
                    .collapsed($model.debuggerSidebarIsCollapsed)
                    .frame(minWidth: 200, idealWidth: 240, maxWidth: 400)
                    .safeAreaInset(edge: .bottom, alignment: .leading) {
                        HStack(spacing: 0) {
                            Button {
                                // fix me
                            } label: {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.icon(size: 29))
                            Button {
                                // fix me
                            } label: {
                                Image(systemName: "minus")
                            }
                            .buttonStyle(.icon(size: 29))
                        }
                        .padding(.leading, 29)
                    }
                    VStack(spacing: 0) {
                        switch model.debuggerTabSelection {
                        case .terminal:
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
                                    // clear logs
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.icon)
                                Divider()
                                HStack(alignment: .center, spacing: 3.5) {
                                    Button {
                                        // split terminal
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
                            .padding(.leading, model.debuggerSidebarIsCollapsed ? 29 : 0)
                            .animation(.default, value: model.debuggerSidebarIsCollapsed)
                            .frame(maxHeight: 28)
                        default:
                            Text("implement me!")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
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
                HStack(spacing: 0) {
                    Button {
                        model.debuggerSidebarIsCollapsed.toggle()
                    } label: {
                        Image(systemName: "square.leadingthird.inset.filled")
                    }
                    .buttonStyle(.icon(isActive: !model.debuggerSidebarIsCollapsed, size: 29))
                    Divider()
                        .frame(height: 12)
                }
            }
        }
    }
}
