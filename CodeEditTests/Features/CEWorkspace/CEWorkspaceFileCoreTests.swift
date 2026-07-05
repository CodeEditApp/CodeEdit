//
//  CEWorkspaceFileCoreTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import XCTest
import CodeEditCore

final class CEWorkspaceFileCoreTests: XCTestCase {

    func testNameAndType() {
        let file = CEWorkspaceFile(url: URL(filePath: "/tmp/Package.swift"))
        XCTAssertEqual(file.name, "Package.swift")
        XCTAssertEqual(file.type, .swift)
    }

    func testTypeDefaultsToTxt() {
        let file = CEWorkspaceFile(url: URL(filePath: "/tmp/no-extension-here"))
        XCTAssertEqual(file.type, .txt)
    }

    func testFileNameTypeHidden() {
        let file = CEWorkspaceFile(url: URL(filePath: "/tmp/Model.swift"))
        XCTAssertEqual(file.fileName(typeHidden: true), "Model")
        XCTAssertEqual(file.fileName(typeHidden: false), "Model.swift")
    }

    func testConvenienceInitUsesRelativePathAsID() {
        let url = URL(filePath: "/tmp/a/b.txt")
        XCTAssertEqual(CEWorkspaceFile(url: url).id, url.relativePath)
    }

    func testEqualityByID() {
        let url = URL(filePath: "/tmp/x.swift")
        XCTAssertEqual(CEWorkspaceFile(url: url), CEWorkspaceFile(url: url))
        XCTAssertNotEqual(
            CEWorkspaceFile(url: URL(filePath: "/tmp/x.swift")),
            CEWorkspaceFile(url: URL(filePath: "/tmp/y.swift"))
        )
    }

    func testComparableByLastPathComponent() {
        let apple = CEWorkspaceFile(url: URL(filePath: "/tmp/a.swift"))
        let banana = CEWorkspaceFile(url: URL(filePath: "/tmp/b.swift"))
        XCTAssertTrue(apple < banana)
    }

    func testCodableRoundTrip() throws {
        // Note: the encoder writes `changeType`/`staged` unconditionally and the decoder
        // requires them non-null, so a valid round-trip needs a concrete gitStatus.
        let original = CEWorkspaceFile(url: URL(filePath: "/tmp/File.swift"), changeType: .modified, staged: true)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CEWorkspaceFile.self, from: data)
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.url, original.url)
        XCTAssertEqual(decoded.gitStatus, .modified)
        XCTAssertEqual(decoded.staged, true)
    }

    func testParentWiring() {
        let parent = CEWorkspaceFile(url: URL(filePath: "/tmp/folder"))
        let child = CEWorkspaceFile(url: URL(filePath: "/tmp/folder/child.swift"))
        child.parent = parent
        XCTAssertTrue(parent.isRoot)
        XCTAssertFalse(child.isRoot)
        XCTAssertIdentical(child.parent, parent)
    }
}
