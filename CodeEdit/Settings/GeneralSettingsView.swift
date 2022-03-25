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
    @AppStorage(ReopenBehavior.storageKey) var reopenBehavior: ReopenBehavior = .default
    @AppStorage(FileIconStyle.storageKey) var fileIconStyle: FileIconStyle = .default

    @StateObject var model = KeyModel.shared

    @State var refresh = UUID()

    var body: some View {
        VStack {
            Preferences.Container(contentWidth: 450) {
                Preferences.Section(title: "Appearance: ") {
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

                            Image("Auto")
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

                            Image("Light")
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

                            Image("Dark")
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

                Preferences.Section(title: "File Icon Style:") {
                    Picker("", selection: $fileIconStyle) {
                        Text("Color".localized())
                            .tag(FileIconStyle.color)
                        Text("Monochrome".localized())
                            .tag(FileIconStyle.monochrome)
                    }
                    .fixedSize()
                }

                Preferences.Section(title: "Reopen Behavior:") {
                    Picker("", selection: $reopenBehavior) {
                        Text("Welcome Screen".localized())
                            .tag(ReopenBehavior.welcome)
                        Divider()
                        Text("Open Panel".localized())
                            .tag(ReopenBehavior.openPanel)
                        Text("New Document".localized())
                            .tag(ReopenBehavior.newDocument)
                    }
                    .fixedSize()
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
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
