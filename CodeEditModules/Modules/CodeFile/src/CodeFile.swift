//
//  CodeFile.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 12/03/2022.
//

import AppKit
import Foundation
import SwiftUI

public enum CodeFileError: Error {
    case failedToDecode
    case failedToEncode
}

@objc(CodeFileDocument)
public final class CodeFileDocument: NSDocument, ObservableObject {
    @Published
    var content = ""

    // MARK: - NSDocument

    override public class var autosavesInPlace: Bool {
        return true
    }

    override public func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let contentView = CodeFileView(codeFile: self)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1400, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.center()
        window.contentView = NSHostingView(rootView: contentView)
        let windowController = NSWindowController(window: window)
        addWindowController(windowController)
    }

    override public func data(ofType _: String) throws -> Data {
        guard let data = content.data(using: .utf8) else { throw CodeFileError.failedToEncode }
        return data
    }

    override public func read(from data: Data, ofType _: String) throws {
        guard let content = String(data: data, encoding: .utf8) else { throw CodeFileError.failedToDecode }
        self.content = content
    }
}
