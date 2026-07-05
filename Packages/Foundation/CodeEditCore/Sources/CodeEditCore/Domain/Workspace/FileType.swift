//
//  FileType.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import Foundation

// swiftlint:disable identifier_name
/// File-type discriminator derived from a file's extension.
public enum FileType: String {
    case adb, aif, avi, bash, c, cetheme, clj, cls, cs, css, d, dart, elm, entitlements
    case env, ex, example, f95, fs, gitignore, go, gs, h, hs, html, ico, java, jl, jpeg
    case jpg, js, json, jsx, kt, l, LICENSE, lock, lsp, lua, m, Makefile, md, mid, mjs
    case mk, mod, mov, mp3, mp4, pas, pdf, pl, plist, png, py, resolved, rb, rs, rtf, scm
    case scpt, sh, ss, strings, sum, svg, swift, ts, tsx
    case txt = "text"
    case vue, wav, xcconfig, yml, zsh
}
// swiftlint:enable identifier_name
