//
//  CodeFileDocument+UTTypeTests.swift
//  CodeEditTests
//
//  Created by Axel Martinez on 23/6/24.
//

import XCTest

@testable import CodeEdit

final class UTTypeTests: XCTestCase {
    private var document: CodeFileDocument!

    override func setUp() {
        document = .init()
    }

    func testTextFileByContent() {
        document.content = NSTextStorage(string: "Some text content")
        XCTAssertEqual(document.utType, .text)
    }

    func testJSONFile() {
        document.fileType = "public.json"
        XCTAssertEqual(document.utType, .json)
    }

    func testTextFileByExtension() {
        document.fileType = "public.python-script"
        XCTAssertEqual(document.utType, .pythonScript)
    }

    func testPdfFile() {
        document.fileType = "com.adobe.pdf"
        XCTAssertEqual(document.utType, .pdf)
    }

    func testImageFile() {
        document.fileType = "public.image"
        XCTAssertEqual(document.utType, .image)
    }

    func testPngFile() {
        document.fileType = "public.png"
        XCTAssertEqual(document.utType, .png)
    }

    func testAudioFile() {
        document.fileType = "public.audio"
        XCTAssertEqual(document.utType, .audio)
    }

    func testMp3File() {
        document.fileType = "public.mp3"
        XCTAssertEqual(document.utType, .mp3)
    }

    func testVideoFile() {
        document.fileType = "public.video"
        XCTAssertEqual(document.utType, .video)
    }

    func testMpeg4File() {
        document.fileType = "public.mpeg-4"
        XCTAssertEqual(document.utType, .mpeg4Movie)
    }

    func testUnknownFileType() {
        document.fileType = "unknown"
        XCTAssertNil(document.utType)
    }

    func testEmptyFileTypeAndContent() {
        XCTAssertNil(document.utType)
    }
}
