//
//  ThemeSettingsView.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/22.
//

import SwiftUI
import CodeEditor
import CodeFile

struct ThemeSettingsView: View {
    @AppStorage(CodeEditorTheme.storageKey) var editorTheme: CodeEditor.ThemeName = .atelierSavannaAuto

    let gridRule = [GridItem](repeating: GridItem(.flexible(), alignment: .top), count: 4)

    var body: some View {
        LazyVGrid(columns: gridRule) {
            ForEach(Theme.all) { themeItem in
                VStack {
                    VStack {
                        themeItem.image
                            .resizable()
                            .frame(width: 116, height: 62)
                            .scaledToFit()
                            .border(Color(hexadecimal: "737373"), width: 1.5)
                            .cornerRadius(3)

                        Text(themeItem.name)
                            .font(.system(size: 12))
                            .multilineTextAlignment(.center)
                    }
                    .padding(5)
                    .background(BackGroundView(seelected: themeItem.selected(editorTheme)))
                }
                .frame(width: 120)
                .padding()
            }
        }
        .frame(width: 650)
        .padding()
    }

    struct BackGroundView: View {
        let seelected: Bool

        var body: some View {
            if seelected {
//                Color(hexadecimal: "464546").cornerRadius(4)
                Color(hexadecimal: "0158D0").cornerRadius(5)
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
