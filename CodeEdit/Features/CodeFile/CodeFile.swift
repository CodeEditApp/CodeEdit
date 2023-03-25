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

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

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
        AppPreferencesModel.shared.preferences.general.isAutoSaveOn
    }

    override var autosavingFileType: String? {
        AppPreferencesModel.shared.preferences.general.isAutoSaveOn
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

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    /// This function is used for decoding files.
    /// It should not throw error as unsupported files can still be opened by QLPreviewView.
    override func read(from data: Data, ofType _: String) throws {
        var encoding: String.Encoding

        switch prefs.preferences.textEditing.textEncoding {
        case .ascii:
            encoding = String.Encoding.ascii
        case .iso2022JP:
            encoding = String.Encoding.iso2022JP
        case .isoLatin1:
            encoding = String.Encoding.isoLatin1
        case .isoLatin2:
            encoding = String.Encoding.isoLatin2
        case .japaneseEUC:
            encoding = String.Encoding.japaneseEUC
        case .macOSRoman:
            encoding = String.Encoding.macOSRoman
        case .nextstep:
            encoding = String.Encoding.nextstep
        case .nonLossyASCII:
            encoding = String.Encoding.nonLossyASCII
        case .shiftJIS:
            encoding = String.Encoding.shiftJIS
        case .symbol:
            encoding = String.Encoding.symbol
        case .unicode:
            encoding = String.Encoding.unicode
        case .utf8:
            encoding = String.Encoding.utf8
        case .utf16:
            encoding = String.Encoding.utf16
        case .utf16be:
            encoding = String.Encoding.utf16BigEndian
        case .utf16le:
            encoding = String.Encoding.utf16LittleEndian
        case .utf32:
            encoding = String.Encoding.utf32
        case .utf32be:
            encoding = String.Encoding.utf32BigEndian
        case .utf32le:
            encoding = String.Encoding.utf32LittleEndian
        }

        guard let content = String(data: data, encoding: encoding) else { return }
        self.content = content
    }
}
