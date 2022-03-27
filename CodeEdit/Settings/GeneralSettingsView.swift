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
    @AppStorage(Appearances.storageKey) var appearance: Appearances = .default
    @AppStorage(FileIconStyle.storageKey) var fileIconStyle: FileIconStyle = .default

    @State var refresh = UUID()

    var body: some View {
        VStack {
            Preferences.Container(contentWidth: 450) {
                Preferences.Section(title: "Appearance:") {
                    AppearenceChangeView(refresh: refresh)
                }

                Preferences.Section(title: "Reopen Behavior:") {
                    ReopenChangeView()
                }

                Preferences.Section(title: "File Icon Style:") {
                    HStack {
                        ColorChoose(selected: $fileIconStyle, selection: .color, colors: [
                            .red, .orange, .yellow, .blue, .green, .purple, .red
                        ])

                        ColorChoose(selected: $fileIconStyle, selection: .monochrome, colors: [
                            .gray
                        ])
                    }
                }
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

    struct ReopenChangeView: View {
        @StateObject var model = KeyModel.shared
        @AppStorage(ReopenBehavior.storageKey) var reopenBehavior: ReopenBehavior = .default
        @AppStorage(Appearances.storageKey) var appearance: Appearances = .default

        var body: some View {
            HStack {
                ZStack(alignment: .center) {
                    if model.key {
                        Color.focusedColor.opacity(reopenBehavior == .welcome ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    } else {
                        Color.unfocusedColor.opacity(reopenBehavior == .welcome ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    }

                    Image(Themes.isDarkMode() ? "welcome window dark" : "welcome window light")
                        .resizable()
                        .frame(width: 67, height: 46)
                        .scaledToFit()
                        .cornerRadius(5)
                        .onTapGesture {
                            reopenBehavior = .welcome
                        }
                }
                .padding(.trailing)

                ZStack(alignment: .center) {
                    if model.key {
                        Color.focusedColor.opacity(reopenBehavior == .openPanel ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    } else {
                        Color.unfocusedColor.opacity(reopenBehavior == .openPanel ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    }

                    Image(appearance == .light ? "open light" : "open dark")
                        .resizable()
                        .frame(width: 67, height: 46)
                        .scaledToFit()
                        .cornerRadius(5)
                        .onTapGesture {
                            reopenBehavior = .openPanel
                        }
                }
                .padding(.trailing)

                ZStack(alignment: .center) {
                    if model.key {
                        Color.focusedColor.opacity(reopenBehavior == .newDocument ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    } else {
                        Color.unfocusedColor.opacity(reopenBehavior == .newDocument ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    }

                    Image(appearance == .light ? "new light" : "new dark")
                        .resizable()
                        .frame(width: 67, height: 46)
                        .scaledToFit()
                        .cornerRadius(5)
                        .onTapGesture {
                            reopenBehavior = .newDocument
                        }
                }
                .padding(.trailing)
            }
        }
    }

    struct AppearenceChangeView: View {
        let refresh: UUID
        @StateObject var model = KeyModel.shared
        @AppStorage(Appearances.storageKey) var appearance: Appearances = .default

        var body: some View {
            HStack {
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
                .padding(.trailing)

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
                .padding(.trailing)

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
