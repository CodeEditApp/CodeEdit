//
//  EditorViewUITests.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 1/5/24.
//

@testable import CodeEdit
import Foundation
import SwiftUI
import XCTest

final class EditorViewTests: XCTestCase {

    struct FocusWrapper: View {
        @FocusState var focus: Editor?
        var editorView: (FocusState<Editor?>.Binding) -> EditorView

        var body: some View {
            editorView($focus)
        }
    }

    private var directory: URL!
    private var files: [EditorInstance] = []
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

        files = fileURLs.map { EditorInstance(file: CEWorkspaceFile(url: $0)) }

        files[1].file.parent = CEWorkspaceFile(url: folder1)
        files[2].file.parent = CEWorkspaceFile(url: folder2)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: directory)
    }

    // MARK: - Empty Editor

    func testEmptyEditor() throws {
        let view = FocusWrapper { focus in
            EditorView(editor: Editor(), focus: focus)
        }.environmentObject(EditorManager())

        snapshot(view: view, named: "Light", size: .init(width: 400, height: 250), appearance: .light)
        snapshot(view: view, named: "Dark", size: .init(width: 400, height: 250), appearance: .dark)
    }

    // MARK: - Editor With Single Selection

    func testSingleTab() throws {
        let tab = EditorInstance(file: CEWorkspaceFile(url: directory.appending(path: "File 1.txt")))

        let view = FocusWrapper { focus in
            EditorView(editor: Editor(files: [tab], selectedTab: tab), focus: focus)
        }
            .environmentObject(mockWorkspace)
            .environmentObject(EditorManager())

        snapshot(view: view, named: "Light", size: .init(width: 500, height: 250), appearance: .light)
        snapshot(view: view, named: "Dark", size: .init(width: 500, height: 250), appearance: .dark)
    }

    // MARK: - Editor With Multiple Tabs

    func testMultipleTab() throws {
        var view = FocusWrapper { focus in
            EditorView(editor: Editor(files: .init(self.files), selectedTab: self.files[2]), focus: focus)
        }
            .environmentObject(mockWorkspace)
            .environmentObject(EditorManager())

        // Test multiple tabs in dark and light modes.
        snapshot(view: view, named: "Tab 1 - Light", size: .init(width: 600, height: 250), appearance: .light)
        snapshot(view: view, named: "Tab 1 - Dark", size: .init(width: 600, height: 250), appearance: .dark)

        // Test overflow
        snapshot(
            view: view,
            named: "Tab 1 - Light - Overflow",
            size: .init(width: 300, height: 250),
            appearance: .light
        )
        snapshot(view: view, named: "Tab 1 - Dark - Overflow", size: .init(width: 300, height: 250), appearance: .dark)

        view = FocusWrapper { focus in
            EditorView(editor: Editor(files: .init(self.files), selectedTab: self.files[1]), focus: focus)
        }
        .environmentObject(mockWorkspace)
        .environmentObject(EditorManager())

        // Test multiple tabs in dark and light modes.
        snapshot(view: view, named: "Tab 2 - Light", size: .init(width: 600, height: 250), appearance: .light)
        snapshot(view: view, named: "Tab 2 - Dark", size: .init(width: 600, height: 250), appearance: .dark)

        // Test overflow
        snapshot(
            view: view,
            named: "Tab 2 - Light - Overflow",
            size: .init(width: 300, height: 250),
            appearance: .light
        )
        snapshot(view: view, named: "Tab 2 - Dark - Overflow", size: .init(width: 300, height: 250), appearance: .dark)
    }

    // MARK: - Temporary Tab

    func testTemporaryTab() throws {
        let editor = Editor(files: .init(self.files), selectedTab: self.files[2])
        editor.temporaryTab = self.files[2]

        var view = FocusWrapper { focus in
            EditorView(editor: editor, focus: focus)
        }
            .environmentObject(mockWorkspace)
            .environmentObject(EditorManager())

        snapshot(view: view, named: "Tab 1 - Light", size: .init(width: 600, height: 250), appearance: .light)
        snapshot(view: view, named: "Tab 1 - Dark", size: .init(width: 600, height: 250), appearance: .dark)

        editor.temporaryTab = self.files[1]
        view = FocusWrapper { focus in
            EditorView(editor: editor, focus: focus)
        }
            .environmentObject(mockWorkspace)
            .environmentObject(EditorManager())

        snapshot(view: view, named: "Tab 2 - Light", size: .init(width: 600, height: 250), appearance: .light)
        snapshot(view: view, named: "Tab 2 - Dark", size: .init(width: 600, height: 250), appearance: .dark)
    }
}
