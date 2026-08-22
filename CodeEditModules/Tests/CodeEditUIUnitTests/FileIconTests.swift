//
//  FileIconTests.swift
//  CodeEditUIUnitTests
//
//  Created by Matthijs Eikelenboom on 05/08/2026.
//

import XCTest
import SwiftUI
@testable import CodeEditUI

/// The table itself was proven exhaustively against the pre-existing mapping by a
/// temporary parity test in the app target — see commit `ba5beee2`, which compared
/// every one of the 73 legacy file types for both symbol and colour. These tests
/// guard the behaviour that survives it.
final class FileIconTests: XCTestCase {

    private func spec(_ filename: String) -> FileIconSpec {
        FileIcon.spec(for: URL(fileURLWithPath: "/tmp/\(filename)"))
    }

    func testRepresentativeExtensions() {
        XCTAssertEqual(spec("main.swift").symbol, "swift")
        XCTAssertEqual(spec("Package.resolved").symbol, "doc.json")
        XCTAssertEqual(spec("script.py").symbol, "doc.python")
        XCTAssertEqual(spec("photo.jpg").symbol, "photo")
    }

    func testWholeFilenameAndDotfileMatches() {
        XCTAssertEqual(spec("LICENSE").symbol, "key.fill")
        XCTAssertEqual(spec("Makefile").symbol, "terminal")
        XCTAssertEqual(spec(".gitignore").symbol, "arrow.triangle.branch")
        XCTAssertEqual(spec(".env").symbol, "gearshape.fill")
        XCTAssertEqual(spec(".env.example").symbol, "gearshape.fill")
    }

    func testLastExtensionWins() {
        XCTAssertEqual(spec("types.d.ts").symbol, "t.square")
    }

    func testTheFourDeliberateFixes() {
        XCTAssertEqual(spec("app.ts").symbol, "t.square")
        XCTAssertEqual(spec("main.c").symbol, "c.square")
        XCTAssertEqual(NSColor(spec("a.jpeg").color), NSColor(spec("a.jpg").color))
        XCTAssertEqual(spec("mystery.qqzz").symbol, "doc")
    }

    func testKnownPlainTextLanguagesDoNotRegressToBareDoc() {
        for ext in ["md", "txt", "kt", "lua", "hs", "dart"] {
            XCTAssertEqual(spec("file.\(ext)").symbol, "doc.plaintext", "\(ext) regressed")
        }
    }

    /// Extensions absent from the table but declared to the system still get a
    /// meaningful icon. Only types macOS actually declares are asserted here —
    /// `.mkv`, for instance, is undeclared on a stock install (see the test below).
    func testSystemFallbackIdentifiesDeclaredTypes() {
        XCTAssertEqual(spec("art.heic").symbol, "photo")
        XCTAssertEqual(spec("art.webp").symbol, "photo")
        XCTAssertEqual(spec("clip.webm").symbol, "film")
        XCTAssertEqual(spec("song.flac").symbol, "speaker.wave.2")
        XCTAssertEqual(spec("Config.toml").symbol, "doc.plaintext")
    }

    /// `UTType(filenameExtension:)` does **not** return nil for unknown extensions —
    /// it synthesises a dynamic `dyn.…` type that conforms to nothing. Undeclared
    /// extensions therefore fall through the conformance checks to bare `doc`.
    func testUndeclaredExtensionsFallThroughToBareDoc() {
        for ext in ["mkv", "zig", "qqzz"] {
            XCTAssertEqual(spec("file.\(ext)").symbol, "doc", "\(ext) should fall through")
        }
    }

    func testFolderSpecs() {
        XCTAssertEqual(
            FileIcon.folderSpec(isEmpty: false, isRoot: true, isCodeEditDirectory: false).symbol,
            "folder.fill.badge.gearshape"
        )
        XCTAssertEqual(
            FileIcon.folderSpec(isEmpty: false, isRoot: false, isCodeEditDirectory: true).symbol,
            "folder.fill.badge.gearshape"
        )
        XCTAssertEqual(
            FileIcon.folderSpec(isEmpty: true, isRoot: false, isCodeEditDirectory: false).symbol,
            "folder"
        )
        XCTAssertEqual(
            FileIcon.folderSpec(isEmpty: false, isRoot: false, isCodeEditDirectory: false).symbol,
            "folder.fill"
        )
    }

    func testGenericSpec() {
        XCTAssertEqual(FileIcon.generic.symbol, "doc")
    }

    /// Guards the package resource wiring: if `Resources` is ever dropped from the
    /// manifest, every colour silently becomes unresolved rather than failing to build.
    func testCustomColorAssetsResolveFromThePackageBundle() {
        for name in ["Amber", "Scarlet", "Steel"] {
            XCTAssertNotNil(
                NSColor(named: name, bundle: .module),
                "\(name) missing from the CodeEditUI asset catalog"
            )
        }
    }

    /// The three custom colours must differ from each other — a failed asset lookup
    /// would collapse them to the same fallback and still pass a nil-check.
    func testCustomColorsAreDistinct() {
        let amber = NSColor(spec("app.js").color)
        let scarlet = NSColor(spec("data.json").color)
        let steel = NSColor(spec("Info.plist").color)
        XCTAssertNotEqual(amber, scarlet)
        XCTAssertNotEqual(scarlet, steel)
        XCTAssertNotEqual(amber, steel)
    }
}
