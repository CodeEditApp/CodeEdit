//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 30.03.22.
//

import FontPicker
import SwiftUI
import Preferences

// swiftlint:disable all
@available(macOS 12, *)
public struct ThemePreferencesView: View {
    @Environment(\.colorScheme)
    var colorScheme

    @ObservedObject
    private var themeModel: ThemeModel = .shared

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            frame
            HStack(alignment: .center) {
                Toggle("Automatically change theme based on system appearance", isOn: .constant(true))
                Spacer()
                Button("Get More Themes...") {}
                HelpButton {}
            }
        }
        .frame(width: 872)
        .padding()
        .onAppear {
            try? themeModel.loadThemes()
        }
    }

    private var frame: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 1) {
                sidebar
                settingsContent
            }
            .padding(1)
            .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))
            .frame(height: 468)
        }
    }

    private var sidebar: some View {
        VStack(spacing: 1) {
            toolbar {
                let options = [
                    "Dark Mode",
                    "Light Mode"
                ]
                SegmentedControl($themeModel.selectedAppearance, options: options)
            }
            ScrollView {
                let grid: [GridItem] = .init(
                    repeating: .init(.fixed(130), spacing: 20, alignment: .center),
                    count: 2
                )
                LazyVGrid(columns: grid,
                          alignment: .center,
                          spacing: 20) {
                    ForEach(themeModel.selectedAppearance == 0 ? themeModel.darkThemes : themeModel.lightThemes) { theme in
                        ThemePreviewIcon(
                            theme,
                            selection: $themeModel.selectedTheme,
                            colorScheme: themeModel.selectedAppearance == 0 ? .dark : .light
                        )
                            .transition(.opacity)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color(NSColor.controlBackgroundColor))
            toolbar {
                sidebarBottomToolbar
            }
            .frame(height: 27)
        }
        .frame(width: 320)
    }

    private var sidebarBottomToolbar: some View {
        HStack {
            Button {} label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.plain)
            Button {} label: {
                Image(systemName: "minus")
            }
            .buttonStyle(.plain)
            Divider()
            Button { try? themeModel.loadThemes() } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
            Spacer()
            Button {} label: {
                Image(systemName: "list.dash")
            }
            .buttonStyle(.plain)
            Button {} label: {
                Image(systemName: "square.grid.2x2")
            }
            .buttonStyle(.plain)
        }
    }

    private var settingsContent: some View {
        VStack(spacing: 1) {
            let options = [
                "Preview",
                "Editor",
                "Terminal"
            ]
            toolbar {
                SegmentedControl($themeModel.selectedTab, options: options)
            }
            switch themeModel.selectedTab {
            case 1:
                EditorThemeView()
            case 2:
                TerminalThemeView()
            default:
                PreviewThemeView()
            }
            toolbar {
                HStack {
                    Spacer()
                    Button {} label: {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func toolbar<T: View>(
        height: Double = 27,
        bgColor: Color = Color(NSColor.controlBackgroundColor),
        @ViewBuilder content: @escaping () -> T
    ) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(bgColor)
            HStack {
                content()
                    .padding(.horizontal, 8)
            }
        }
        .frame(height: height)
    }
}

@available(macOS 12, *)
struct PrefsThemes_Previews: PreviewProvider {
    static var previews: some View {
        ThemePreferencesView()
            .preferredColorScheme(.light)
    }
}
