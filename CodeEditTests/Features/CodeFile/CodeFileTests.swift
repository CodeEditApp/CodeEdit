//
//  UnitTests.swift
//  CodeEditModules/CodeFileTests
//
//  Created by Marco Carnevali on 18/03/22.
//

import Foundation
import SwiftUI
import XCTest
@testable import CodeEdit

final class CodeFileUnitTests: XCTestCase {
    var fileURL: URL!

    override func setUp() async throws {
        let directory = try FileManager.default.url(
            for: .developerApplicationDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
            .appendingPathComponent("CodeEdit", isDirectory: true)
            .appendingPathComponent("WorkspaceClientTests", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("fakeFile.swift")
    }

    func testLoadUTF8Encoding() throws {
        let fileContent = "func test(){}"

        try fileContent.data(using: .utf8)?.write(to: fileURL)
        let codeFile = try CodeFileDocument(
            for: fileURL,
            withContentsOf: fileURL,
            ofType: "public.source-code"
        )
        XCTAssertEqual(codeFile.content?.string, fileContent)
        XCTAssertEqual(codeFile.sourceEncoding, .utf8)
    }

    func testWriteUTF8Encoding() throws {
        let codeFile = CodeFileDocument()
        codeFile.content = NSTextStorage(string: "func test(){}")
        codeFile.sourceEncoding = .utf8
        try codeFile.write(to: fileURL, ofType: "public.source-code")

        let data = try Data(contentsOf: fileURL)
        var nsString: NSString?
        let fileEncoding = NSString.stringEncoding(
            for: data,
            encodingOptions: [
                .suggestedEncodingsKey: FileEncoding.allCases.map { $0.nsValue },
                .useOnlySuggestedEncodingsKey: true
            ],
            convertedString: &nsString,
            usedLossyConversion: nil
        )

        XCTAssertEqual(codeFile.content?.string as NSString?, nsString)
        XCTAssertEqual(fileEncoding, NSUTF8StringEncoding)
    }
}
