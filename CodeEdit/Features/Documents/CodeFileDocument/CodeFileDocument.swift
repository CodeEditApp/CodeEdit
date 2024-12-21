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
import OSLog

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

    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "CodeFileDocument")

    /// Sent when the document is opened. The document will be sent in the notification's object.
    static let didOpenNotification = Notification.Name(rawValue: "CodeFileDocument.didOpen")
    /// Sent when the document is closed. The document's `fileURL` will be sent in the notification's object.
    static let didCloseNotification = Notification.Name(rawValue: "CodeFileDocument.didClose")

    /// The text content of the document, stored as a text storage
    ///
    /// This is intentionally not a `@Published` variable. If it were published, SwiftUI would do a string
    /// compare each time the contents are updated, which could cause a hang on each keystroke if the file is large
    /// enough.
    ///
    /// To receive notifications for content updates, subscribe to one of the publishers on ``contentCoordinator``.
    var content: NSTextStorage?

    /// The string encoding of the original file. Used to save the file back to the encoding it was loaded from.
    var sourceEncoding: FileEncoding?

    /// The coordinator to use to subscribe to edit events and cursor location events.
    /// See ``CodeEditSourceEditor/CombineCoordinator``.
    @Published var contentCoordinator: CombineCoordinator = CombineCoordinator()

    /// Set by ``LanguageServer`` when initialized.
    @Published var lspCoordinator: LSPContentCoordinator?

    /// Used to override detected languages.
    @Published var language: CodeLanguage?

    /// Document-specific overridden indent option.
    @Published var indentOption: SettingsData.TextEditingSettings.IndentOption?

    /// Document-specific overridden tab width.
    @Published var defaultTabWidth: Int?

    /// Document-specific overridden line wrap preference.
    @Published var wrapLines: Bool?

    /// The type of data this file document contains.
    ///
    /// If its text content is not nil, a `text` UTType is returned.
    ///
    /// - Note: The UTType doesn't necessarily mean the file extension, it can be the MIME
    /// type or any other form of data representation.
    var utType: UTType? {
        if content != nil {
            return .text
        }

        guard let fileType, let type = UTType(fileType) else {
            return nil
        }

        return type
    }

    /// A stable string to use when identifying documents with language servers.
    var languageServerURI: String? { fileURL?.absolutePath }

    /// Specify options for opening the file such as the initial cursor positions.
    /// Nulled by ``CodeFileView`` on first load.
    var openOptions: OpenOptions?

    private let isDocumentEditedSubject = PassthroughSubject<Bool, Never>()

    /// Publisher for isDocumentEdited property
    var isDocumentEditedPublisher: AnyPublisher<Bool, Never> {
        isDocumentEditedSubject.eraseToAnyPublisher()
    }

    // MARK: - NSDocument

    override static var autosavesInPlace: Bool {
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
        guard let sourceEncoding, let data = (content?.string as NSString?)?.data(using: sourceEncoding.nsValue) else {
            Self.logger.error("Failed to encode contents to \(self.sourceEncoding.debugDescription)")
            throw CodeFileError.failedToEncode
        }
        return data
    }

    /// This function is used for decoding files.
    /// It should not throw error as unsupported files can still be opened by QLPreviewView.
    override func read(from data: Data, ofType _: String) throws {
        var nsString: NSString?
        let rawEncoding = NSString.stringEncoding(
            for: data,
            encodingOptions: [
                .allowLossyKey: false, // Fail if using lossy encoding.
                .suggestedEncodingsKey: FileEncoding.allCases.map { $0.nsValue },
                .useOnlySuggestedEncodingsKey: true
            ],
            convertedString: &nsString,
            usedLossyConversion: nil
        )
        if let validEncoding = FileEncoding(rawEncoding), let nsString {
            self.sourceEncoding = validEncoding
            self.content = NSTextStorage(string: nsString as String)
        } else {
            Self.logger.error("Failed to read file from data using encoding: \(rawEncoding)")
        }
        NotificationCenter.default.post(name: Self.didOpenNotification, object: self)
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

    override func close() {
        super.close()
        NotificationCenter.default.post(name: Self.didCloseNotification, object: fileURL)
    }

    func getLanguage() -> CodeLanguage {
        guard let url = fileURL else {
            return .default
        }
        return language ?? CodeLanguage.detectLanguageFrom(
            url: url,
            prefixBuffer: content?.string.getFirstLines(5),
            suffixBuffer: content?.string.getLastLines(5)
        )
    }

    func findWorkspace() -> WorkspaceDocument? {
        fileURL?.findWorkspace()
    }
}
