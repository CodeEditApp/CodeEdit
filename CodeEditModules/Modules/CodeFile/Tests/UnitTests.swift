//
//  UnitTests.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 18/03/22.
//
@testable import CodeFile
import Foundation
import SnapshotTesting
import SwiftUI
import XCTest

final class CodeFileUnitTests: XCTestCase {
    func testViewSnapshot() throws {
        let directory = try FileManager.default.url(for: .developerApplicationDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("CodeEdit", isDirectory: true)
            .appendingPathComponent("WorkspaceClientTests", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let fileURL = directory.appendingPathComponent("fakeFile.md")

        try "Fake String".data(using: .utf8)?.write(to: fileURL)
        let codeFile = try CodeFileDocument(
            for: fileURL,
            withContentsOf: fileURL,
            ofType: "public.source-code"
        )
        let view = CodeFileView(codeFile: codeFile)
        let hosting = NSHostingView(rootView: view)
        hosting.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        assertSnapshot(matching: hosting, as: .image)
    }
}
