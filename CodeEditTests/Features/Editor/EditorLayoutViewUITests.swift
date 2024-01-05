//
//  EditorLayoutViewUITests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 1/5/24.
//

@testable import CodeEdit
import Foundation
import SnapshotTesting
import SwiftUI
import XCTest

final class EditorLayoutViewUITests: XCTestCase {
    struct FocusWrapper: View {
        @FocusState var focus: Editor?
        var editorView: (FocusState<Editor?>.Binding) -> EditorLayoutView

        var body: some View {
            editorView($focus)
        }
    }

    private var directory: URL!
    private var files: [CEWorkspaceFile] = []
    private var mockWorkspace: WorkspaceDocument!

    // MARK: - Setup

    override func setUp() async throws {
        directory = try FileManager.default.url(
            for: .developerApplicationDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("CodeEdit", isDirectory: true)
        .appendingPathComponent("WorkspaceClientTests", isDirectory: true)
        try? FileManager.default.removeItem(at: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        mockWorkspace = try await WorkspaceDocument(for: directory, withContentsOf: directory, ofType: "")

        // Add a few files
        let folder1 = directory.appending(path: "Folder 2")
        let folder2 = directory.appending(path: "Longer Folder With Some 💯 SPecial Chars ⁉️")
        try FileManager.default.createDirectory(
            at: folder1,
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: folder2,
            withIntermediateDirectories: true
        )

        let fileURLs = [
            directory.appending(path: "File 1.txt"),
            folder1.appending(path: "Documentation.docc"),
            folder2.appending(path: "Makefile")
        ]

        for url in fileURLs {
            try String("Loren Ipsum").write(to: url, atomically: true, encoding: .utf8)
        }

        files = fileURLs.map { CEWorkspaceFile(url: $0) }

        files[1].parent = CEWorkspaceFile(url: folder1)
        files[2].parent = CEWorkspaceFile(url: folder2)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: directory)
    }

    // MARK: - Split Editor

    func testSplitEditorHorizontalLight() {
        let editorLeft = Editor(files: [], selectedTab: nil)
        let editorRight = Editor(files: [], selectedTab: nil)
        let layout: EditorLayout = .horizontal(.init(.horizontal, editorLayouts: [.one(editorLeft), .one(editorRight)]))

        let view = FocusWrapper { focus in
            EditorLayoutView(layout: layout, focus: focus)
        }
            .environmentObject(mockWorkspace)
            .environmentObject(EditorManager())

        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 800, height: 800))
        assertSnapshot(of: hosting, as: .image)
    }

    func testSplitEditorHorizontalDark() {
        let editorLeft = Editor(files: [], selectedTab: nil)
        let editorRight = Editor(files: [], selectedTab: nil)
        let layout: EditorLayout = .horizontal(.init(.horizontal, editorLayouts: [.one(editorLeft), .one(editorRight)]))

        let view = FocusWrapper { focus in
            EditorLayoutView(layout: layout, focus: focus)
        }
            .environmentObject(mockWorkspace)
            .environmentObject(EditorManager())

        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 800, height: 800))
        assertSnapshot(of: hosting, as: .image)
    }

    func testSplitEditorVerticalLight() {
        let editorLeft = Editor(files: [], selectedTab: nil)
        let editorRight = Editor(files: [], selectedTab: nil)
        let layout: EditorLayout = .vertical(.init(.vertical, editorLayouts: [.one(editorLeft), .one(editorRight)]))

        let view = FocusWrapper { focus in
            EditorLayoutView(layout: layout, focus: focus)
        }
            .environmentObject(mockWorkspace)
            .environmentObject(EditorManager())

        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 800, height: 800))
        assertSnapshot(of: hosting, as: .image)
    }

    func testSplitEditorVerticalDark() {
        let editorLeft = Editor(files: [], selectedTab: nil)
        let editorRight = Editor(files: [], selectedTab: nil)
        let layout: EditorLayout = .vertical(.init(.vertical, editorLayouts: [.one(editorLeft), .one(editorRight)]))

        let view = FocusWrapper { focus in
            EditorLayoutView(layout: layout, focus: focus)
        }
            .environmentObject(mockWorkspace)
            .environmentObject(EditorManager())

        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 800, height: 800))
        assertSnapshot(of: hosting, as: .image)
    }

    // MARK: - Split Editor Single Selection

    // MARK: - Split Editor Multiple Tabs

    // MARK: - Split Editor Different Tab Selections
}
