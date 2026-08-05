//
//  FileIcon.swift
//  CodeEditUI
//
//  Created by Matthijs Eikelenboom on 05/08/2026.
//

import SwiftUI
import UniformTypeIdentifiers
import CodeEditSymbols

/// The symbol and tint used to represent a file or folder.
public struct FileIconSpec: Sendable, Equatable {
    public let symbol: String
    public let color: Color

    public init(symbol: String, color: Color) {
        self.symbol = symbol
        self.color = color
    }
}

public extension FileIconSpec {
    /// SwiftUI image, preferring a `CodeEditSymbols` custom symbol.
    var image: Image {
        if let custom = NSImage.symbol(named: symbol) {
            return Image(nsImage: custom)
        }
        return Image(systemName: symbol)
    }

    /// AppKit image, preferring a `CodeEditSymbols` custom symbol.
    var nsImage: NSImage {
        if let custom = NSImage.symbol(named: symbol) {
            return custom
        }
        return NSImage(systemSymbolName: symbol, accessibilityDescription: symbol)
            ?? NSImage(systemSymbolName: "doc", accessibilityDescription: "doc")!
    }
}

/// Maps files to a symbol and tint.
///
/// Keyed on the file's *name*, not on a domain type, so this stays free of model
/// dependencies and can live beside the other presentation atoms.
public enum FileIcon {

    // Resolved from this package's own asset catalog, so the package is
    // self-contained and its tests can assert colours without an app host.
    private static let amber = Color("Amber", bundle: .module)
    private static let scarlet = Color("Scarlet", bundle: .module)
    private static let steel = Color("Steel", bundle: .module)

    /// Used when no file is known. Matches the old `fileIcon(fileType: nil)`.
    public static let generic = FileIconSpec(symbol: "doc", color: Color("Steel", bundle: .module))

    /// Whole-filename matches, checked before any extension.
    private static let byFilename: [String: FileIconSpec] = [
        "LICENSE": .init(symbol: "key.fill", color: amber),
        "Makefile": .init(symbol: "terminal", color: Color(red: 0.937, green: 0.325, blue: 0.314))
    ]

    private static let byExtension: [String: FileIconSpec] = [
        // structured data
        "json": .init(symbol: "doc.json", color: scarlet),
        "yml": .init(symbol: "doc.json", color: scarlet),
        "resolved": .init(symbol: "doc.json", color: scarlet),
        "strings": .init(symbol: "text.quote", color: scarlet),
        "plist": .init(symbol: "tablecells", color: steel),
        "lock": .init(symbol: "lock.doc", color: steel),
        // web
        "css": .init(symbol: "curlybraces", color: .teal),
        "html": .init(symbol: "chevron.left.forwardslash.chevron.right", color: .orange),
        "js": .init(symbol: "doc.javascript", color: amber),
        "mjs": .init(symbol: "doc.javascript", color: amber),
        "ts": .init(symbol: "t.square", color: .blue),
        "jsx": .init(symbol: "atom", color: .cyan),
        "tsx": .init(symbol: "atom", color: .cyan),
        "vue": .init(symbol: "v.square", color: Color(red: 0.255, green: 0.722, blue: 0.514)),
        // languages
        "swift": .init(symbol: "swift", color: .orange),
        "java": .init(symbol: "cup.and.saucer", color: .blue),
        "py": .init(symbol: "doc.python", color: amber),
        "rb": .init(symbol: "doc.ruby", color: scarlet),
        "c": .init(symbol: "c.square", color: .purple),
        "h": .init(symbol: "h.square", color: Color(red: 0.667, green: 0.031, blue: 0.133)),
        "m": .init(symbol: "m.square", color: Color(red: 0.271, green: 0.106, blue: 0.525)),
        "go": .init(symbol: "g.square", color: Color(red: 0.02, green: 0.675, blue: 0.757)),
        "sum": .init(symbol: "s.square", color: Color(red: 0.925, green: 0.251, blue: 0.478)),
        "mod": .init(symbol: "m.square", color: Color(red: 0.925, green: 0.251, blue: 0.478)),
        "rs": .init(symbol: "r.square", color: .orange),
        // shells
        "bash": .init(symbol: "terminal", color: steel),
        "sh": .init(symbol: "terminal", color: steel),
        "zsh": .init(symbol: "terminal", color: steel),
        "scpt": .init(symbol: "applescript", color: steel),
        // config
        "env": .init(symbol: "gearshape.fill", color: steel),
        "example": .init(symbol: "gearshape.fill", color: steel),
        "gitignore": .init(symbol: "arrow.triangle.branch", color: steel),
        "entitlements": .init(symbol: "checkmark.seal", color: amber),
        "xcconfig": .init(symbol: "gearshape.2", color: steel),
        "cetheme": .init(symbol: "paintbrush", color: .purple),
        // media
        "png": .init(symbol: "photo", color: .blue),
        "jpg": .init(symbol: "photo", color: .blue),
        "jpeg": .init(symbol: "photo", color: .blue),
        "ico": .init(symbol: "photo", color: .blue),
        "svg": .init(symbol: "square.fill.on.circle.fill", color: .blue),
        "pdf": .init(symbol: "photo", color: steel),
        "wav": .init(symbol: "speaker.wave.2", color: steel),
        "mp3": .init(symbol: "speaker.wave.2", color: steel),
        "aif": .init(symbol: "speaker.wave.2", color: steel),
        "mid": .init(symbol: "speaker.wave.2", color: steel),
        "avi": .init(symbol: "film", color: steel),
        "mp4": .init(symbol: "film", color: steel),
        "mov": .init(symbol: "film", color: steel),
        // documents
        "rtf": .init(symbol: "doc.richtext", color: steel),
        "md": .init(symbol: "doc.plaintext", color: steel),
        "txt": .init(symbol: "doc.plaintext", color: steel),
        "text": .init(symbol: "doc.plaintext", color: steel)
    ].merging(
        // Known plain-text languages. Explicit entries, not fallbacks — without
        // them these would regress to bare `doc`.
        [
            "adb", "clj", "cls", "cs", "d", "dart", "elm", "ex", "f95", "fs", "gs",
            "hs", "jl", "kt", "l", "lsp", "lua", "mk", "pas", "pl", "scm", "ss"
        ].reduce(into: [:]) { dict, ext in
            dict[ext] = FileIconSpec(symbol: "doc.plaintext", color: steel)
        },
        uniquingKeysWith: { current, _ in current }
    )

    /// Spec for the file at `url`.
    public static func spec(for url: URL) -> FileIconSpec {
        let filename = url.lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines)

        if let match = byFilename[filename] {
            return match
        }

        // Leading-dot names (.gitignore, .env.example) — drop the dot, then treat
        // the remainder as an extension chain.
        let searchable = filename.hasPrefix(".") ? String(filename.dropFirst()) : filename

        // Last extension wins: `file.d.ts` resolves `ts` before `d`.
        for component in searchable.components(separatedBy: ".").reversed() {
            if let match = byExtension[component] {
                return match
            }
        }

        return systemSpec(for: url) ?? FileIconSpec(symbol: "doc", color: steel)
    }

    /// Spec for a folder.
    public static func folderSpec(
        isEmpty: Bool,
        isRoot: Bool,
        isCodeEditDirectory: Bool
    ) -> FileIconSpec {
        if isRoot || isCodeEditDirectory {
            return .init(symbol: "folder.fill.badge.gearshape", color: steel)
        }
        return .init(symbol: isEmpty ? "folder" : "folder.fill", color: steel)
    }

    /// Fallback for extensions the table does not cover, using the system's
    /// declared type. Keeps unrecognised-but-identifiable files meaningful.
    private static func systemSpec(for url: URL) -> FileIconSpec? {
        guard let type = UTType(filenameExtension: url.pathExtension) else { return nil }
        if type.conforms(to: .image) { return .init(symbol: "photo", color: steel) }
        if type.conforms(to: .audio) { return .init(symbol: "speaker.wave.2", color: steel) }
        if type.conforms(to: .audiovisualContent) { return .init(symbol: "film", color: steel) }
        if type.conforms(to: .sourceCode) || type.conforms(to: .text) {
            return .init(symbol: "doc.plaintext", color: steel)
        }
        return nil
    }
}
