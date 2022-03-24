//
//  ThemeSettingsView.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/23.
//

import SwiftUI
import CodeFile
import Preferences
import SwiftUIKeyPress

struct ThemeSettingsView: View {
    @AppStorage(CodeFileView.Theme.storageKey) var editorTheme: CodeFileView.Theme = .atelierSavannaAuto

    let gridRule = [GridItem](repeating: GridItem(.flexible(), alignment: .top), count: 5)

    @State var keyWindow = true
    @State var refresh = UUID()

    @StateObject var model = KeyModel.shared

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridRule) {
                ForEach(Themes.all) { themeItem in
                    VStack {
                        VStack {
                            if themeItem.selected(editorTheme) {
                                themeItem.image
                                    .resizable()
                                    .frame(width: 116, height: 62)
                                    .scaledToFit()
                                    .cornerRadius(3)
                            } else {
                                themeItem.image
                                    .resizable()
                                    .frame(width: 116, height: 62)
                                    .scaledToFit()
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(lineWidth: 1.5)
                                            .foregroundColor(Color.gray.opacity(0.5))
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                            }

                            Text(themeItem.name)
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 11))
                        }
                        .padding(5)
                        .background(BackGroundView(selected: themeItem.selected(editorTheme)))
                        .onTapGesture {
                            editorTheme = themeItem.theme
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(width: 820, height: 450)
        .padding()
        .onChange(of: model.event) { newValue in
            if let event = newValue {
                if event.keyCode == 124 {
                    Themes.next()
                } else if event.keyCode == 123 {
                    Themes.back()
                }
            }
        }
    }

    struct BackGroundView: View {
        @StateObject var model = KeyModel.shared
        let selected: Bool

        var body: some View {
            if selected {
                if model.key {
                    Color.accentColor.opacity(0.8).cornerRadius(5)
                } else {
                    Color.gray.opacity(0.3).cornerRadius(5)
                }
            } else {
                Color.clear
            }
        }
    }
}

struct ThemeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeSettingsView()
    }
}
