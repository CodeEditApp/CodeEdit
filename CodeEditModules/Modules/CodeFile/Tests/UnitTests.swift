//
//  UnitTests.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 18/03/22.
//
@testable import CodeFile
import Foundation
import SwiftUI
import XCTest

final class CodeFileUnitTests: XCTestCase {
    func testViewContentLoading() throws {
        let directory = try FileManager.default.url(
            for: .developerApplicationDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
            .appendingPathComponent("CodeEdit", isDirectory: true)
            .appendingPathComponent("WorkspaceClientTests", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let fileURL = directory.appendingPathComponent("fakeFile.swift")

        let fileContent = "func test(){}"

        try fileContent.data(using: .utf8)?.write(to: fileURL)
        let codeFile = try CodeFileDocument(
            for: fileURL,
            withContentsOf: fileURL,
            ofType: "public.source-code"
        )
        XCTAssertEqual(codeFile.content, fileContent)
    }
}
