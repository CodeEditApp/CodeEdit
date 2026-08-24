//
//  CompletionItemKind.swift
//  CodeEdit
//
//  Created by Abe Malla on 10/05/24.
//

import SwiftUI
import LanguageServerProtocol

extension CompletionItemKind {
    var symbolName: String {
        switch self {
        case .text:
            "t.square.fill"
        case .method, .module:
            "m.square.fill"
        case .function:
            "curlybraces.square.fill"
        case .constructor, .interface:
            "i.square.fill"
        case .field, .class, .color:
            "c.square.fill"
        case .variable:
            "v.square.fill"
        case .property:
            "p.square.fill"
        case .unit:
            "u.square.fill"
        case .value:
            "n.square.fill"
        case .enum, .enumMember, .event:
            "e.square.fill"
        case .keyword, .constant:
            "k.square.fill"
        case .snippet, .struct:
            "s.square.fill"
        case .file:
            "d.square.fill"
        case .reference:
            "r.square.fill"
        case .folder:
            "f.square.fill"
        case .operator:
            "plus.slash.minus"
        case .typeParameter:
            "t.square.fill"
        }
    }

    var swiftUIColor: SwiftUI.Color {
        switch self {
        case .text,
                .function,
                .interface,
                .module,
                .unit,
                .value,
                .color,
                .file,
                .reference,
                .folder,
                .enumMember,
                .constant,
                .struct,
                .event,
                .operator,
                .typeParameter:
            Color.blue
        case .variable:
            Color.green
        case .method:
            Color.cyan
        case .constructor:
            Color.teal
        case .field:
            Color.indigo
        case .class:
            Color.pink
        case .property:
            Color.purple
        case .enum:
            Color.mint
        case .keyword:
            Color.pink
        case .snippet:
            Color.purple
        }
    }
}
