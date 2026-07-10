//
//  FileIcon.swift
//  Editor
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI
import CodeEditCore

enum FileIcon {

    static func fileIcon(fileType: FileType?) -> String { // swiftlint:disable:this cyclomatic_complexity function_body_length
        switch fileType {
        case .json, .yml, .resolved:
            return "doc.json"
        case .lock:
            return "lock.doc"
        case .css:
            return "curlybraces"
        case .js, .mjs:
            return "doc.javascript"
        case .jsx, .tsx:
            return "atom"
        case .swift:
            return "swift"
        case .env, .example:
            return "gearshape.fill"
        case .gitignore:
            return "arrow.triangle.branch"
        case .pdf, .png, .jpg, .jpeg, .ico:
            return "photo"
        case .svg:
            return "square.fill.on.circle.fill"
        case .entitlements:
            return "checkmark.seal"
        case .plist:
            return "tablecells"
        case .md, .txt:
            return "doc.plaintext"
        case .rtf:
            return "doc.richtext"
        case .html:
            return "chevron.left.forwardslash.chevron.right"
        case .LICENSE:
            return "key.fill"
        case .java:
            return "cup.and.saucer"
        case .py:
            return "doc.python"
        case .rb:
            return "doc.ruby"
        case .strings:
            return "text.quote"
        case .h:
            return "h.square"
        case .m:
            return "m.square"
        case .vue:
            return "v.square"
        case .go:
            return "g.square"
        case .sum:
            return "s.square"
        case .mod:
            return "m.square"
        case .bash, .sh, .Makefile, .zsh:
            return "terminal"
        case .rs:
            return "r.square"
        case .wav, .mp3, .aif, .mid:
            return "speaker.wave.2"
        case .avi, .mp4, .mov:
            return "film"
        case .scpt:
            return "applescript"
        case .xcconfig:
            return "gearshape.2"
        case .cetheme:
            return "paintbrush"
        case .adb, .clj, .cls, .cs, .d, .dart, .elm, .ex, .f95, .fs, .gs, .hs,
             .jl, .kt, .l, .lsp, .lua, .mk, .pas, .pl, .scm, .ss:
            return "doc.plaintext"
        default:
            return "doc"
        }
    }

    static func iconColor(fileType: FileType?) -> Color { // swiftlint:disable:this cyclomatic_complexity
        switch fileType {
        case .swift, .html:
            return .orange
        case .java, .jpg, .png, .svg, .ts:
            return .blue
        case .css:
            return .teal
        case .js, .mjs, .py, .entitlements, .LICENSE:
            return Color("Amber", bundle: .main)
        case .json, .resolved, .rb, .strings, .yml:
            return Color("Scarlet", bundle: .main)
        case .jsx, .tsx:
            return .cyan
        case .plist, .xcconfig, .sh:
            return Color("Steel", bundle: .main)
        case .c, .cetheme:
            return .purple
        case .vue:
            return Color(red: 0.255, green: 0.722, blue: 0.514, opacity: 1.0)
        case .h:
            return Color(red: 0.667, green: 0.031, blue: 0.133, opacity: 1.0)
        case .m:
            return Color(red: 0.271, green: 0.106, blue: 0.525, opacity: 1.0)
        case .go:
            return Color(red: 0.02, green: 0.675, blue: 0.757, opacity: 1.0)
        case .sum, .mod:
            return Color(red: 0.925, green: 0.251, blue: 0.478, opacity: 1.0)
        case .Makefile:
            return Color(red: 0.937, green: 0.325, blue: 0.314, opacity: 1.0)
        case .rs:
            return .orange
        default:
            return Color("Steel", bundle: .main)
        }
    }
}
