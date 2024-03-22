//
//  FileIcon.swift
//  
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

// TODO: DOCS (Nanashi Li)
enum FileIcon {

    // swiftlint:disable identifier_name
    enum FileType: String {
        case adb
        case aif
        case avi
        case bash
        case c
        case cetheme
        case clj
        case cls
        case cs
        case css
        case d
        case dart
        case elm
        case entitlements
        case env
        case ex
        case example
        case f95
        case fs
        case gitignore
        case go
        case gs
        case h
        case hs
        case html
        case ico
        case java
        case jl
        case jpeg
        case jpg
        case js
        case json
        case jsx
        case kt
        case l
        case LICENSE
        case lock
        case lsp
        case lua
        case m
        case Makefile
        case md
        case mid
        case mjs
        case mk
        case mod
        case mov
        case mp3
        case mp4
        case pas
        case pdf
        case pl
        case plist
        case png
        case py
        case resolved
        case rb
        case rs
        case rtf
        case scm
        case scpt
        case sh
        case ss
        case strings
        case sum
        case svg
        case swift
        case ts
        case tsx
        case txt = "text"
        case vue
        case wav
        case xcconfig
        case yml
        case zsh
    }

    // swiftlint:enable identifier_name

    /// Returns a string describing a SFSymbol for files
    /// If not specified otherwise this will return `"doc"`
    static func fileIcon(fileType: FileType) -> String { // swiftlint:disable:this cyclomatic_complexity function_body_length line_length
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

    /// Returns a `Color` for a specific `fileType`
    /// If not specified otherwise this will return `Color.accentColor`
    static func iconColor(fileType: FileType) -> Color { // swiftlint:disable:this cyclomatic_complexity
        switch fileType {
        case .swift, .html:
            return .orange
        case .java, .jpg, .png, .svg, .ts:
            return .blue
        case .css:
            return .teal
        case .js, .mjs, .py, .entitlements, .LICENSE:
            return Color("Amber")
        case .json, .resolved, .rb, .strings, .yml:
            return Color("Scarlet")
        case .jsx, .tsx:
            return .cyan
        case .plist, .xcconfig, .sh:
            return Color("Steel")
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
            return Color("Steel")
        }
    }
}
