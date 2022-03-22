//
//  Theme.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/22.
//

import Foundation
import CodeEditor
import SwiftUI

/// This is struct for ThemeSettingView
struct Theme: Identifiable {
    static let all: [Self] = [
        .init(name: "Default", theme: .default, image: Image("AgateDisplay")),
        .init(name: "Atelier Savanna (Auto)", theme: .atelierSavannaAuto, image: Self.getAtelierSavannaAutoImage()),
        .init(name: "Atelier Savanna Dark", theme: .atelierSavannaDark, image: Image("Atelier Savanna Dark Display")),
        .init(name: "Atelier Savanna Light", theme: .atelierSavannaLight,
              image: Image("Atelier Savanna Light Display")),
        .init(name: "Agate", theme: .agate, image: Image("AgateDisplay")),
        .init(name: "Ocean", theme: .ocean, image: Image("OceanDisplay"))
    ]

    let id = UUID()
    let name: String
    let theme: CodeEditor.ThemeName

    /// 550 * 350
    let image: Image

    private static func getAtelierSavannaAutoImage() -> Image {
        if NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            return Image("Atelier Savanna Dark Display")
        } else {
            return Image("Atelier Savanna Light Display")
        }
    }
}
