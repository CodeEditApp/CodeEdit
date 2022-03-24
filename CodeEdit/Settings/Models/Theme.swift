//
//  Theme.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/23.
//

import SwiftUI
import CodeFile

/// This is sturct for ThemeSettingsView
struct Themes: Identifiable {
    static let all: [Themes] = [
        .init(name: "Atelier Savanna Auto", theme: .atelierSavannaAuto,
              image: isDarkMode() ? "Atelier Savanna Dark" : "Atelier Savanna Light"),
        .init(name: "Atelier Savanna Dark", theme: .atelierSavannaDark, image: "Atelier Savanna Dark"),
        .init(name: "Atelier Savanna Light", theme: .atelierSavannaLight, image: "Atelier Savanna Light"),
        .init(name: "Agate", theme: .agate, image: "Agate"),
        .init(name: "Ocean", theme: .ocean, image: "Ocean")
    ]

    let id = UUID()
    let name: String
    let theme: CodeFileView.Theme

    /// 580 * 310
    let image: Image

    init(name: String, theme: CodeFileView.Theme, image: String) {
        self.name = name
        self.theme = theme
        self.image = Image(image)
    }

    /// Tell the appearence
    static func isDarkMode() -> Bool {
        NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }

    func selected(_ editorTheme: CodeFileView.Theme) -> Bool {
        return editorTheme == self.theme
    }

    static func next() {
        @AppStorage(CodeFileView.Theme.storageKey) var editorTheme: CodeFileView.Theme = .atelierSavannaAuto
        if let firstIndex = Self.all.firstIndex(where: { theme in
            theme.theme == editorTheme
        }) {
            let index: Int

            if firstIndex + 1 >= Self.all.count {
                index = 0
            } else {
                index = firstIndex + 1
            }

            editorTheme = Self.all[index].theme
        }
    }

    static func back() {
        @AppStorage(CodeFileView.Theme.storageKey) var editorTheme: CodeFileView.Theme = .atelierSavannaAuto
        if let firstIndex = Self.all.firstIndex(where: { theme in
            theme.theme == editorTheme
        }) {
            let index: Int

            if firstIndex - 1 < 0 {
                index = Self.all.endIndex - 1
            } else {
                index = firstIndex - 1
            }

            editorTheme = Self.all[index].theme
        }
    }
}
