//
//  FileIcon.swift
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

// TODO: DOCS (Nanashi Li)
// swiftlint:disable cyclomatic_complexity
enum FileIcon {

    // swiftlint:disable identifier_name
    enum FileType: String {
        case pyw
        case pyc
        case docx
        case docm
        case doc
        case lz
        case gcode
        case pns
        case pnm
        case jng
        case xml
        case gsh
        case gy
        case gvy
        case groovy
        case pkg
        case dmg
        case htm
        case gzip
        case obj
        case dae
        case abc
        case glb
        case stl
        case ply
        case blend
        case ai
        case heic
        case gif
        case tga
        case bmp
        case psd
        case hdr
        case pic
        case webp
        case avif
        case ppm
        case pgm
        case pbm
        case tiff
        case tif
        case pdf
        case mp3
        case wav
        case mov
        case mp4
        case asm
        case app
        case s
        case inc
        case wla
        case src
        case json
        case js
        case ruby
        case c
        case cc
        case hpp
        case cpp
        case cobol
        case cs
        case css
        case d
        case kotlin
        case julia
        case jsx
        case php
        case perl
        case lua
        case scala
        case sql
        case svelte
        case zip
        case gz
        case tar
        case swift
        case env
        case example
        case gitignore
        case png
        case jpg
        case jpeg
        case ico
        case svg
        case entitlements
        case plist
        case md
        case txt = "text"
        case rtf
        case r
        case rust
        case html
        case py
        case sh
        case LICENSE
        case java
        case jar
        case h
        case m
        case vue
        case go
        case sum
        case mod
        case Makefile
        case ts
        case warningRemover // Removes warning
    }

    // swiftlint:disable function_body_length
    /// Returns a string describing a SFSymbol for files
    /// If not specified otherwise this will return `"doc"`
    static func fileIcon(fileType: FileType) -> String {
        switch fileType {
        case .groovy, .gvy, .gy, .gsh:
            return "star"
        case .pkg:
            return "archivebox"
        case .dmg:
            return "externaldrive"
        case .obj, .dae, .abc, .glb, .stl, .ply, .blend, .gcode:
            return "move.3d"
        case .mp3, .wav:
            return "waveform"
        case .mov, .mp4:
            return "video.square"
        case .app:
            return "app.dashed"
        case .asm, .s, .inc, .wla, .src, .doc, .docm, .docx:
            return "doc.text"
        case .zip, .tar, .gz, .gzip, .lz:
            return "doc.zipper"
        case .json, .js, .xml:
            return "curlybraces"
        case .cobol:
            return "c.square.fill"
        case .cs:
            return "number.square"
        case .css:
            return "number"
        case .jsx:
            return "atom"
        case .lua:
            return "l.circle"
        case .julia:
            return "j.square"
        case .swift:
            return "swift"
        case .sql, .scala:
            return "cylinder.split.1x2"
        case .env, .example:
            return "gearshape.fill"
        case .gitignore:
            return "arrow.triangle.branch"
        // swiftlint:disable line_length
        case .png, .jpg, .jpeg, .ico, .heic, .gif, .tga, .bmp, .psd, .hdr, .pic, .webp, .avif, .ppm, .pgm, .pbm, .pnm, .tiff, .pdf, .ai, .jng, .pns:
            return "photo"
        case .svg:
            return "square.fill.on.circle.fill"
        case .entitlements:
            return "checkmark.seal"
        case .plist:
            return "tablecells"
        case .php:
            return "oval.fill"
        case .md, .txt, .rtf:
            return "doc.plaintext"
        case .html, .py, .sh, .htm, .pyc, .pyw:
            return "chevron.left.forwardslash.chevron.right"
        case .kotlin:
            return "k.square"
        case .LICENSE:
            return "key.fill"
        case .java:
            return "cup.and.saucer"
        case .c:
            return "c.square"
        case .cpp, .cc, .hpp:
            return "plus.app"
        case .d:
            return "d.square"
        case .h:
            return "h.square"
        case .m:
            return "m.square"
        case .perl:
            return "p.square"
        case .vue:
            return "v.square"
        case .go:
            return "g.square"
        case .sum, .svelte:
            return "s.square"
        case .mod:
            return "m.square"
        case .Makefile:
            return "terminal"
        case .r, .rust, .ruby:
            return "r.square"
        case .ts:
            return "t.square"
        default:
            return "doc"
        }
    }

    /// Returns a `Color` for a specific `fileType`
    /// If not specified otherwise this will return `Color.accentColor`
    static func iconColor(fileType: FileType) -> Color {
        switch fileType {
        case .julia, .perl, .app, .mov, .mp4:
            return .gray
        case .swift, .html, .sql, .htm:
            return .orange
        case .java, .svelte, .scala, .ruby, .d:
            return .red
        case .js, .entitlements, .json, .LICENSE:
            return Color("SidebarYellow")
        case .c, .cpp, .css, .ts, .jsx, .r, .md, .py, .lua, .cobol, .cc, .groovy, .gvy, .gy, .gsh, .xml:
            return .blue
        case .cs, .sh, .lz:
            return .green
        case .doc, .docm, .docx:
            return Color(red: 0.168, green: 0.336, blue: 0.690, opacity: 1.0)
        case .mp3, .wav:
            return Color(red: 0.227, green: 0.494, blue: 0.780, opacity: 1.0)
        case .zip, .tar, .gz:
            return Color(red: 0.278, green: 0.329, blue: 0.882, opacity: 1.0)
        case .asm, .s, .inc, .wla, .src:
            return Color(red: 0.152, green: 0.196, blue: 0.282, opacity: 1.0)
        case .php:
            return Color(red: 0.470, green: 0.482, blue: 0.686, opacity: 1.0)
        case .vue:
            return Color(red: 0.255, green: 0.722, blue: 0.514, opacity: 1.0)
        case .h, .hpp:
            return Color(red: 0.667, green: 0.031, blue: 0.133, opacity: 1.0)
        case .m:
            return Color(red: 0.271, green: 0.106, blue: 0.525, opacity: 1.0)
        case .go:
            return Color(red: 0.020, green: 0.675, blue: 0.757, opacity: 1.0)
        case .sum, .mod:
            return Color(red: 0.925, green: 0.251, blue: 0.478, opacity: 1.0)
        case .Makefile:
            return Color(red: 0.937, green: 0.325, blue: 0.314, opacity: 1.0)
        default:
            return .accentColor
        }
    }
}
