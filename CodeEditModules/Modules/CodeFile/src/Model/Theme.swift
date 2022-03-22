//
//  Theme.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 19/03/22.
//

extension CodeFileView {
    public enum Theme: String {
        public static let storageKey = "codeEditorTheme"

        case agate
        case ocean
        case atelierSavannaDark = "atelier-savanna-dark"
        case atelierSavannaLight = "atelier-savanna-light"
        case atelierSavannaAuto = "atelier-savanna-auto"
    }
}
