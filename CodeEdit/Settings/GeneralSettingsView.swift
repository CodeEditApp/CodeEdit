//
//  GeneralSettingsView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 11.03.22.
//

import SwiftUI
import CodeFile
import Preferences

// MARK: - View

struct GeneralSettingsView: View {
    @AppStorage(Appearances.storageKey)
    var appearance: Appearances = .default

    @AppStorage(ReopenBehavior.storageKey)
    var reopenBehavior: ReopenBehavior = .default

    @AppStorage(FileIconStyle.storageKey)
    var fileIconStyle: FileIconStyle = .default

    @AppStorage(CodeFileView.Theme.storageKey)
    var editorTheme: CodeFileView.Theme = .atelierSavannaAuto

    @AppStorage(EditorTabWidth.storageKey)
    var defaultTabWidth: Int = EditorTabWidth.default

    @State var refresh = UUID()

    var body: some View {
        Form {
            AppearenceChangeView(refresh: refresh)
                .formLabel(Text("Appearence:".localized()))

            Picker("File Icon Style:".localized(), selection: $fileIconStyle) {
                Text("Color".localized())
                    .tag(FileIconStyle.color)
                Text("Monochrome".localized())
                    .tag(FileIconStyle.monochrome)
            }
            .fixedSize()

            Picker("Reopen Behavior:".localized(), selection: $reopenBehavior) {
                Text("Welcome Screen".localized())
                    .tag(ReopenBehavior.welcome)
                Divider()
                Text("Open Panel".localized())
                    .tag(ReopenBehavior.openPanel)
                Text("New Document".localized())
                    .tag(ReopenBehavior.newDocument)
            }
            .fixedSize()

            HStack {
                Stepper("Default Tab Width:".localized(), value: $defaultTabWidth, in: 2...8)
                Text(String(defaultTabWidth))
            }

            Spacer()
        }
        .onChange(of: appearance) { tag in
            tag.applyAppearance()
            refresh = UUID()
        }
        .padding()
        .frame(width: 820, height: 450)
    }

    struct AppearenceChangeView: View {
        let refresh: UUID
        @StateObject var model = KeyModel.shared
        @AppStorage(Appearances.storageKey) var appearance: Appearances = .default

        var body: some View {
            HStack {
                VStack {
                    ZStack(alignment: .center) {
                        if model.key {
                            Color.focusedColor.opacity(appearance == .system || appearance == .default ? 1 : 0)
                                .frame(width: 67 + 3, height: 46 + 3)
                                .cornerRadius(5)
                        } else {
                            Color.unfocusedColor.opacity(appearance == .system || appearance == .default ? 1 : 0)
                                .frame(width: 67 + 3, height: 46 + 3)
                                .cornerRadius(5)
                        }

                        Image("Settings Image - Auto")
                            .resizable()
                            .frame(width: 67, height: 46)
                            .scaledToFit()
                            .cornerRadius(5)
                            .onTapGesture {
                                appearance = .system
                            }
                    }

                    Text("Auto".localized())
                }
                .padding(.trailing)

                VStack {
                    ZStack(alignment: .center) {
                        if model.key {
                            Color.focusedColor.opacity(appearance == .light ? 1 : 0)
                                .frame(width: 67 + 3, height: 46 + 3)
                                .cornerRadius(5)
                        } else {
                            Color.unfocusedColor.opacity(appearance == .light ? 1 : 0)
                                .frame(width: 67 + 3, height: 46 + 3)
                                .cornerRadius(5)
                        }

                        Image("Settings Image - Light")
                            .resizable()
                            .frame(width: 67, height: 46)
                            .scaledToFit()
                            .cornerRadius(5)
                            .onTapGesture {
                                appearance = .light
                            }
                    }

                    Text("Light".localized())
                }
                .padding(.trailing)

                VStack {
                    ZStack(alignment: .center) {
                        if model.key {
                            Color.focusedColor.opacity(appearance == .dark ? 1 : 0)
                                .frame(width: 67 + 3, height: 46 + 3)
                                .cornerRadius(5)
                        } else {
                            Color.unfocusedColor.opacity(appearance == .dark ? 1 : 0)
                                .frame(width: 67 + 3, height: 46 + 3)
                                .cornerRadius(5)
                        }

                        Image("Settings Image - Dark")
                            .resizable()
                            .frame(width: 67, height: 46)
                            .scaledToFit()
                            .cornerRadius(5)
                            .onTapGesture {
                                appearance = .dark
                            }
                    }

                    Text("Dark".localized())
                }
                .padding(.trailing)
            }
            .id(refresh)
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
