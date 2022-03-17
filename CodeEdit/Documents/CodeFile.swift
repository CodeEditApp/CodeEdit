//
//  CodeFile.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 12/03/2022.
//

import Foundation
import AppKit
import SwiftUI

enum CodeFileError: Error {
    case failedToDecode
    case failedToEncode
}

@objc(CodeFile)
class CodeFile: NSDocument, ObservableObject {
    
    @Published var text = ""
    
    // MARK: - NSDocument
    
    override class var autosavesInPlace: Bool {
        return true
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let contentView = CodeFileEditor(file: self)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.contentView = NSHostingView(rootView: contentView)
        let windowController = NSWindowController(window: window)
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        guard let data = self.text.data(using: .utf8) else { throw CodeFileError.failedToEncode }
        return data
    }

    override func read(from data: Data, ofType typeName: String) throws {
        guard let text = String(data: data, encoding: .utf8) else { throw CodeFileError.failedToDecode }
        self.text = text
    }
}
