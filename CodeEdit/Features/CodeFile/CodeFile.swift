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

enum CodeFileError: Error {
    case failedToDecode
    case failedToEncode
    case fileTypeError
}

@objc(CodeFileDocument)
final class CodeFileDocument: NSDocument, ObservableObject, QLPreviewItem {

    @Published
    var content = ""

    /*
     This is the main type of the document.
     For example, if the file is end with '.png', it will be an image,
     if the file is end with '.py', it will be a text file.
     If text content is not empty, return text
     If its neither image or text, this could be nil.
    */
    var typeOfFile: UTType? {
        if !self.content.isEmpty {
            return UTType.text
        }
        guard let fileType, let type = UTType(fileType) else {
            return nil
        }
        if type.conforms(to: UTType.image) {
            return UTType.image
        }
        if type.conforms(to: UTType.text) {
            return UTType.text
        }
        if type.conforms(to: .data) {
            return .data
        }
        return nil
    }

    /*
     This is the QLPreviewItemURL
     */
    var previewItemURL: URL? {
        fileURL
    }

    @Published
    var cursorPosition = (1, 1)

    // MARK: - NSDocument

    override class var autosavesInPlace: Bool {
        SettingsModel.shared.preferences.general.isAutoSaveOn
    }

    override var autosavingFileType: String? {
        SettingsModel.shared.preferences.general.isAutoSaveOn
            ? fileType
            : nil
    }

    override func makeWindowControllers() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1400, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        let windowController = NSWindowController(window: window)
        addWindowController(windowController)

        window.contentView = NSHostingView(rootView: WindowCodeFileView(codeFile: self))

        window.makeKeyAndOrderFront(nil)
        window.center()
    }

    override func data(ofType _: String) throws -> Data {
        guard let data = content.data(using: .utf8) else { throw CodeFileError.failedToEncode }
        return data
    }

    /// This function is used for decoding files.
    /// It should not throw error as unsupported files can still be opened by QLPreviewView.
    override func read(from data: Data, ofType _: String) throws {
        guard let content = String(data: data, encoding: .utf8) else { return }
        self.content = content
    }
}
