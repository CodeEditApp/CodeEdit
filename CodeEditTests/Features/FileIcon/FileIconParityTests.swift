//
//  FileIconParityTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 05/08/2026.
//

import XCTest
import SwiftUI
import CodeEditCore
import CodeEditUI
@testable import CodeEdit

/// Temporary: proves the new `CodeEditUI.FileIcon` table reproduces the old
/// mapping. Deleted together with `FileType` in the final commit of this slice.
///
/// Both sides are qualified explicitly — `FileIcon` alone is ambiguous while the
/// app target still declares its own copy.
final class FileIconParityTests: XCTestCase {

    /// Every raw value declared by `FileType`, in declaration order.
    private let rawValues = [
        "adb", "aif", "avi", "bash", "c", "cetheme", "clj", "cls", "cs", "css", "d",
        "dart", "elm", "entitlements", "env", "ex", "example", "f95", "fs",
        "gitignore", "go", "gs", "h", "hs", "html", "ico", "java", "jl", "jpeg",
        "jpg", "js", "json", "jsx", "kt", "LICENSE", "lock", "lsp", "lua", "m",
        "Makefile", "md", "mid", "mjs", "mk", "mod", "mov", "mp3", "mp4", "pas",
        "pdf", "pl", "plist", "png", "py", "resolved", "rb", "rs", "rtf", "scm",
        "scpt", "sh", "ss", "strings", "sum", "svg", "swift", "text", "ts", "tsx",
        "vue", "wav", "xcconfig", "yml", "zsh"
    ]

    /// The deliberate fixes: raw value → expected new symbol.
    private let symbolExceptions = ["ts": "t.square", "c": "c.square"]
    /// Raw values whose colour deliberately changes (to `jpg`'s blue).
    private let colorExceptions: Set<String> = ["jpeg", "ico"]

    private func url(for rawValue: String) -> URL {
        // LICENSE and Makefile match on the whole filename; everything else is an extension.
        ["LICENSE", "Makefile"].contains(rawValue)
            ? URL(fileURLWithPath: "/tmp/\(rawValue)")
            : URL(fileURLWithPath: "/tmp/file.\(rawValue)")
    }

    private func rgba(_ color: Color) -> [CGFloat] {
        guard let converted = NSColor(color).usingColorSpace(.sRGB) else {
            return []
        }
        return [
            converted.redComponent, converted.greenComponent,
            converted.blueComponent, converted.alphaComponent
        ]
    }

    func testSymbolsMatchLegacyMapping() {
        for rawValue in rawValues {
            guard let type = FileType(rawValue: rawValue) else {
                XCTFail("FileType(rawValue: \(rawValue)) is nil — raw-value list is stale")
                continue
            }
            let new = CodeEditUI.FileIcon.spec(for: url(for: rawValue)).symbol
            let expected = symbolExceptions[rawValue] ?? CodeEdit.FileIcon.fileIcon(fileType: type)
            XCTAssertEqual(new, expected, "symbol mismatch for \(rawValue)")
        }
    }

    func testColorsMatchLegacyMapping() {
        for rawValue in rawValues where !colorExceptions.contains(rawValue) {
            guard let type = FileType(rawValue: rawValue) else { continue }
            let new = CodeEditUI.FileIcon.spec(for: url(for: rawValue)).color
            XCTAssertEqual(
                rgba(new), rgba(CodeEdit.FileIcon.iconColor(fileType: type)),
                "color mismatch for \(rawValue)"
            )
        }
    }

    func testDeliberateExceptions() {
        // jpeg/ico now share jpg's blue.
        let jpg = CodeEditUI.FileIcon.spec(for: url(for: "jpg")).color
        for rawValue in colorExceptions {
            XCTAssertEqual(
                rgba(CodeEditUI.FileIcon.spec(for: url(for: rawValue)).color), rgba(jpg),
                "\(rawValue) should share jpg's color"
            )
        }
        // Unidentifiable files get bare `doc`, not `doc.plaintext`.
        let unknown = CodeEditUI.FileIcon.spec(for: URL(fileURLWithPath: "/tmp/file.qqzz"))
        XCTAssertEqual(unknown.symbol, "doc")
        // The generic (no-file) spec is unchanged.
        XCTAssertEqual(
            CodeEditUI.FileIcon.generic.symbol,
            CodeEdit.FileIcon.fileIcon(fileType: nil)
        )
    }
}
