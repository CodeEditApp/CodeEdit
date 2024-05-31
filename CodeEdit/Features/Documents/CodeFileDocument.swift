//
//  CodeFileDocument.swift
//  CodeEditModules/CodeFile
//
//  Created by Rehatbir Singh on 12/03/2022.
//

import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers
import CodeEditSourceEditor
import CodeEditTextView
import CodeEditLanguages
import Combine

enum CodeFileError: Error {
    case failedToDecode
    case failedToEncode
    case fileTypeError
}

@objc(CodeFileDocument)
final class CodeFileDocument: NSDocument, ObservableObject {
    struct OpenOptions {
        let cursorPositions: [CursorPosition]
    }

    @Published var content = ""

    /// Used to override detected languages.
    @Published var language: CodeLanguage?

    /// Document-specific overridden indent option.
    @Published var indentOption: SettingsData.TextEditingSettings.IndentOption?

    /// Document-specific overridden tab width.
    @Published var defaultTabWidth: Int?

    /// Document-specific overridden line wrap preference.
    @Published var wrapLines: Bool?

    /// The type of data this document contains.
    ///
    /// If for example, the file ends with `.py`, its type is a text file.
    /// Or if it ends with `.png`, then it is an image.
    /// Same goes for PDF and video formats.
    ///
    /// Also, if the text content is not empty, it is a text file.
    ///
    /// - Note: The UTType doesn't necessarily mean the file extension, it can be the MIME
    /// type or any other form of data representation.
    var utType: UTType? {
        if !self.content.isEmpty {
            return .text
        }
        guard let fileType, let type = UTType(fileType) else {
            return nil
        }
        if type.conforms(to: .text) {
            return .text
        }
        if type.conforms(to: .image) {
            return .image
        }
        if type.conforms(to: .pdf) {
            return .pdf
        }
        return type
    }

    /// Specify options for opening the file such as the initial cursor positions.
    /// Nulled by ``CodeFileView`` on first load.
    var openOptions: OpenOptions?

    private let isDocumentEditedSubject = PassthroughSubject<Bool, Never>()

    /// Publisher for isDocumentEdited property
    var isDocumentEditedPublisher: AnyPublisher<Bool, Never> {
        isDocumentEditedSubject.eraseToAnyPublisher()
    }

    // MARK: - NSDocument

    override class var autosavesInPlace: Bool {
        Settings.shared.preferences.general.isAutoSaveOn
    }

    override var autosavingFileType: String? {
        Settings.shared.preferences.general.isAutoSaveOn
            ? fileType
            : nil
    }

    override func makeWindowControllers() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 750, height: 800),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        let windowController = NSWindowController(window: window)
        if let fileURL {
            windowController.shouldCascadeWindows = false
            windowController.windowFrameAutosaveName = fileURL.path
        }
        addWindowController(windowController)

        window.contentView = NSHostingView(rootView: SettingsInjector {
            WindowCodeFileView(codeFile: self)
        })

        window.makeKeyAndOrderFront(nil)

        if let fileURL, UserDefaults.standard.object(forKey: "NSWindow Frame \(fileURL.path)") == nil {
            window.center()
        }
    }

    override func data(ofType _: String) throws -> Data {
        guard let data = content.data(using: .utf8) else { throw CodeFileError.failedToEncode }
        return data
    }

    /// This function is used for decoding files.
    /// It should not throw error as unsupported files can still be opened by QLPreviewView.
    override func read(from data: Data, ofType _: String) throws {
        var nsString: NSString?
        NSString.stringEncoding(for: data, encodingOptions: nil, convertedString: &nsString, usedLossyConversion: nil)
        self.content = nsString as? String ?? ""
    }

    /// Triggered when change occurred
    override func updateChangeCount(_ change: NSDocument.ChangeType) {
        super.updateChangeCount(change)

        if CodeFileDocument.autosavesInPlace {
            return
        }

        self.isDocumentEditedSubject.send(self.isDocumentEdited)
    }

    /// Triggered when changes saved
    override func updateChangeCount(withToken changeCountToken: Any, for saveOperation: NSDocument.SaveOperationType) {
        super.updateChangeCount(withToken: changeCountToken, for: saveOperation)

        if CodeFileDocument.autosavesInPlace {
            return
        }

        self.isDocumentEditedSubject.send(self.isDocumentEdited)
    }
}
