//
//  CodeFile.swift
//  CodeEditModules/CodeFile
//
//  Created by Rehatbir Singh on 12/03/2022.
//

import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers
import QuickLookUI

public enum CodeFileError: Error {
    case failedToDecode
    case failedToEncode
    case fileTypeError
}

@objc(CodeFileDocument)
public final class CodeFileDocument: NSDocument, ObservableObject, QLPreviewItem {

    @Published
    var content = ""

    @Published
    var image: NSImage?

    /*
     This is the main type of the document.
     For example, if the file is end with '.png', it will be an image,
     if the file is end with '.py', it will be a text file.
     If text content is not empty, return text
     If its neither image or text, this could be nil.
    */
    public var typeOfFile: UTType? {
        if !self.content.isEmpty {
            return UTType.text
        }
        guard let fileType = fileType, let type = UTType(filenameExtension: fileType) else {
            return nil
        }
        if type.conforms(to: UTType.image) {
            return UTType.image
        }
        if type.conforms(to: UTType.text) {
            return UTType.text
        }
        return nil
    }

    /*
     This is the QLPreviewItemURL
     */
    public var previewItemURL: URL? {
        fileURL
    }

    // MARK: - NSDocument

    override public class var autosavesInPlace: Bool {
        true
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

    /// This fuction is used for decoding files.
    /// It should not throw error as unsupported files can still be opened by QLPreviewView.
    override public func read(from data: Data, ofType _: String) throws {
        switch typeOfFile {
        case .some(.image):
            guard let image = NSImage(data: data) else { return }
            self.image = image
        default:
            guard let content = String(data: data, encoding: .utf8) else { return }
            self.content = content
        }
    }
}
