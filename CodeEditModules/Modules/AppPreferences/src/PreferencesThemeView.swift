//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 30.03.22.
//

import CodeFile
import FontPicker
import SwiftUI
import Preferences
import TerminalEmulator

// swiftlint:disable all
@available(macOS 12, *)
public struct PreferencesThemeView: View {
    @Environment(\.colorScheme)
    var colorScheme

    @AppStorage(Appearances.storageKey)
    private var appearance: Appearances = .default

    @AppStorage(CodeFileView.Theme.storageKey)
    var editorTheme: CodeFileView.Theme = .atelierSavannaAuto

    @AppStorage(TerminalShellType.storageKey)
    var shellType: TerminalShellType = .default

    @AppStorage(TerminalFont.storageKey)
    var terminalFontSelection: TerminalFont = .default

    @AppStorage(TerminalFontName.storageKey)
    var terminalFontName: String = TerminalFontName.default

    @AppStorage(TerminalFontSize.storageKey)
    var terminalFontSize: Int = TerminalFontSize.default

    @AppStorage(TerminalColorScheme.storageKey)
    var terminalColorSchmeme: TerminalColorScheme = .default

    @StateObject
    private var colors = AnsiColors.shared

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            newEditor
            HStack(alignment: .center) {
                Toggle("Automatically change theme based on system appearance", isOn: .constant(true))
                Spacer()
                Button("Get More Themes...") {}
                HelpButton {}
            }
        }
        .frame(width: 872)
        .padding()
    }

    private var newEditor: some View {
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

    @State
    private var selectedTheme: Int = 0

    private var sidebar: some View {
        VStack(spacing: 1) {
            toolbar {
                CustomSegmentedControl(.constant(0),
                                       options: [
                                        "Dark Mode",
                                        "Light Mode"
                                       ])
            }
            ScrollView {
                let grid: [GridItem] = .init(
                    repeating: .init(.fixed(130), spacing: 20, alignment: .center),
                    count: 2
                )
                LazyVGrid(columns: grid,
                          alignment: .center,
                          spacing: 20) {
                    ForEach(0..<10) { id in
                        ThemePreviewIcon(id, selection: $selectedTheme)
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
            toolbar {
                CustomSegmentedControl(.constant(1),
                                       options: [
                                        "Preview",
                                        "Editor",
                                        "Terminal"
                                       ])
            }
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .foregroundColor(Color(NSColor.controlBackgroundColor))
                VStack(alignment: .leading, spacing: 0) {
                    Toggle("Use theme background ", isOn: .constant(true))
                        .padding(.bottom, 20)
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 10) {
                            colorPicker(.constant(Color(hex: 0xffffff)), label: "Text")
                            colorPicker(.constant(Color(hex: 0xffffff)), label: "Cursor")
                            colorPicker(.constant(Color(hex: 0x636363)), label: "Invisibles")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        VStack(alignment: .leading, spacing: 10) {
                            colorPicker(.constant(Color(hex: 0x1e1e1e)), label: "Background")
                            colorPicker(.constant(Color(hex: 0x303030)), label: "Current Line")
                            colorPicker(.constant(Color(hex: 0x8b8b8b)), label: "Selection")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.bottom, 20)
                    Text("Syntax")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 10) {
                            colorPicker(.constant(Color(hex: 0xef8bb6)), label: "Keywords")
                            colorPicker(.constant(Color(hex: 0xc6a3f9)), label: "Commands")
                            colorPicker(.constant(Color(hex: 0x93c7bc)), label: "Types")
                            colorPicker(.constant(Color(hex: 0x93c7bc)), label: "Attributes")
                            colorPicker(.constant(Color(hex: 0x70c1e2)), label: "Variables")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        VStack(alignment: .leading, spacing: 10) {
                            colorPicker(.constant(Color(hex: 0x70c1e2)), label: "Values")
                            colorPicker(.constant(Color(hex: 0xd6c775)), label: "Numbers")
                            colorPicker(.constant(Color(hex: 0xf0907f)), label: "Strings")
                            colorPicker(.constant(Color(hex: 0x93c7bc)), label: "Characters")
                            colorPicker(.constant(Color(hex: 0x97be71)), label: "Comments")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
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

    private var editor: some View {
        Form {
            Picker("Editor Theme", selection: $editorTheme) {
                Text("Atelier Savanna (Auto)")
                    .tag(CodeFileView.Theme.atelierSavannaAuto)
                Text("Atelier Savanna Dark")
                    .tag(CodeFileView.Theme.atelierSavannaDark)
                Text("Atelier Savanna Light")
                    .tag(CodeFileView.Theme.atelierSavannaLight)
                Text("Agate")
                    .tag(CodeFileView.Theme.agate)
                Text("Ocean")
                    .tag(CodeFileView.Theme.ocean)
            }
            .fixedSize()
        }
    }

    private var terminal: some View {
        Form {
            Picker("Terminal Shell", selection: $shellType) {
                Text("System Default")
                    .tag(TerminalShellType.auto)
                Divider()
                Text("ZSH")
                    .tag(TerminalShellType.zsh)
                Text("Bash")
                    .tag(TerminalShellType.bash)
            }
            .fixedSize()

            Picker("Terminal Appearance", selection: $terminalColorSchmeme) {
                Text("App Default")
                    .tag(TerminalColorScheme.auto)
                Divider()
                Text("Light")
                    .tag(TerminalColorScheme.light)
                Text("Dark")
                    .tag(TerminalColorScheme.dark)
            }
            .fixedSize()

            Picker("Terminal Font", selection: $terminalFontSelection) {
                Text("System Font")
                    .tag(TerminalFont.systemFont)
                Divider()
                Text("Custom")
                    .tag(TerminalFont.custom)
            }
            .fixedSize()
            if terminalFontSelection == .custom {
                FontPicker(
                    "\(terminalFontName) \(terminalFontSize)",
                    name: $terminalFontName,
                    size: $terminalFontSize
                )
            }
            Divider()
                .frame(maxWidth: 400)
            Section {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        ansiColorPicker($colors.colors[0])
                        ansiColorPicker($colors.colors[1])
                        ansiColorPicker($colors.colors[2])
                        ansiColorPicker($colors.colors[3])
                        ansiColorPicker($colors.colors[4])
                        ansiColorPicker($colors.colors[5])
                        ansiColorPicker($colors.colors[6])
                        ansiColorPicker($colors.colors[7])
                        Text("Normal").padding(.leading, 4)
                    }
                    HStack(spacing: 0) {
                        ansiColorPicker($colors.colors[8])
                        ansiColorPicker($colors.colors[9])
                        ansiColorPicker($colors.colors[10])
                        ansiColorPicker($colors.colors[11])
                        ansiColorPicker($colors.colors[12])
                        ansiColorPicker($colors.colors[13])
                        ansiColorPicker($colors.colors[14])
                        ansiColorPicker($colors.colors[15])
                        Text("Bright").padding(.leading, 4)
                    }
                }
            }
            Button("Restore Defaults") {
                AnsiColors.shared.resetDefault()
            }
        }
    }

    private func colorPicker(_ color: Binding<Color>, label: String) -> some View {
        HStack {
            ColorPicker(selection: color, supportsOpacity: false) { }
                .labelsHidden()
            Text(label)
        }
    }

    private func ansiColorPicker(_ color: Binding<Color>) -> some View {
        ColorPicker(selection: color, supportsOpacity: false) { }
            .labelsHidden()
    }
}

@available(macOS 12, *)
struct PrefsThemes_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesThemeView()
            .preferredColorScheme(.light)
    }
}

@available(macOS 12, *)
struct CustomSegmentedControl: View {

    init(_ selection: Binding<Int>, options: [String]) {
        self._preselectedIndex = selection
        self.options = options
    }

    @Binding var preselectedIndex: Int
    var options: [String]
    let color = Color.accentColor
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                Text(options[index])
                    .font(.subheadline)
                    .foregroundColor(preselectedIndex == index ? .white : .primary)
                    .frame(height: 16)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background {
                        Rectangle()
                        .fill(color)
                        .cornerRadius(5)
                        .padding(2)
                        .opacity(preselectedIndex == index ? 1 : 0.01)
                    }
                    .onTapGesture {
                        withAnimation(.interactiveSpring()) {
                            preselectedIndex = index
                        }
                    }
            }
        }
        .frame(height: 20)
    }
}
