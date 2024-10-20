//
//  CompletionItemKind.swift
//  CodeEdit
//
//  Created by Abe Malla on 10/05/24.
//

import SwiftUI
import LanguageServerProtocol

extension CompletionItemKind {
    static func toSymbolName(kind: CompletionItemKind?) -> String {
        let defaultSymbol = "dot.square.fill"

        guard let kind = kind else {
            return defaultSymbol
        }

        let symbolMap: [CompletionItemKind: String] = [
            .text: "t.square.fill",
            .method: "m.square.fill",
            .function: "curlybraces.square.fill",
            .constructor: "i.square.fill",
            .field: "c.square.fill",
            .variable: "v.square.fill",
            .class: "c.square.fill",
            .interface: "i.square.fill",
            .module: "m.square.fill",
            .property: "p.square.fill",
            .unit: "u.square.fill",
            .value: "n.square.fill",
            .enum: "e.square.fill",
            .keyword: "k.square.fill",
            .snippet: "s.square.fill",
            .color: "c.square.fill",
            .file: "d.square.fill",
            .reference: "r.square.fill",
            .folder: "f.square.fill",
            .enumMember: "e.square.fill",
            .constant: "k.square.fill",
            .struct: "s.square.fill",
            .event: "e.square.fill",
            .operator: "plus.slash.minus",
            .typeParameter: "t.square.fill"
        ]
        return symbolMap[kind] ?? defaultSymbol
    }

    static func toSymbolColor(kind: CompletionItemKind?) -> SwiftUICore.Color {
        let defaultColor = Color.gray

        guard let kind = kind else {
            return defaultColor
        }

        let symbolMap: [CompletionItemKind: SwiftUICore.Color] = [
            .text: Color.blue,
            .method: Color.blue,
            .function: Color.blue,
            .constructor: Color.teal,
            .field: Color.blue,
            .variable: Color.blue,
            .class: Color.pink,
            .interface: Color.blue,
            .module: Color.blue,
            .property: Color.secondary,
            .unit: Color.blue,
            .value: Color.blue,
            .enum: Color.blue,
            .keyword: Color.blue,
            .snippet: Color.blue,
            .color: Color.blue,
            .file: Color.blue,
            .reference: Color.blue,
            .folder: Color.blue,
            .enumMember: Color.blue,
            .constant: Color.blue,
            .struct: Color.blue,
            .event: Color.blue,
            .operator: Color.blue,
            .typeParameter: Color.blue,
        ]
        return symbolMap[kind] ?? defaultColor
    }
}
