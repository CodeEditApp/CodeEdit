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
import TextStory

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

    /// Used to override detected languages.
    @Published var language: CodeLanguage?

    /// Document-specific overridden indent option.
    @Published var indentOption: SettingsData.TextEditingSettings.IndentOption?

    /// Document-specific overridden tab width.
    @Published var defaultTabWidth: Int?

    /// Document-specific overridden line wrap preference.
    @Published var wrapLines: Bool?

    /// Set up by ``LanguageServer``, conforms this type to ``LanguageServerDocument``.
    @Published var languageServerObjects: LanguageServerDocumentObjects<CodeFileDocument> = .init()

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

    /// Specify options for opening the file such as the initial cursor positions.
    /// Nulled by ``CodeFileView`` on first load.
    var openOptions: OpenOptions?

    private let isDocumentEditedSubject = PassthroughSubject<Bool, Never>()

    /// Publisher for isDocumentEdited property
    var isDocumentEditedPublisher: AnyPublisher<Bool, Never> {
        isDocumentEditedSubject.eraseToAnyPublisher()
    }

    /// A lock that ensures autosave scheduling happens correctly.
    private var autosaveTimerLock: NSLock = NSLock()
    /// Timer used to schedule autosave intervals.
    private var autosaveTimer: Timer?

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

    // MARK: - Data

    override func data(ofType _: String) throws -> Data {
        guard let sourceEncoding, let data = (content?.string as NSString?)?.data(using: sourceEncoding.nsValue) else {
            Self.logger.error("Failed to encode contents to \(self.sourceEncoding.debugDescription)")
            throw CodeFileError.failedToEncode
        }
        return data
    }

    // MARK: - Read

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
        guard let validEncoding = FileEncoding(rawEncoding), let nsString else {
            Self.logger.error("Failed to read file from data using encoding: \(rawEncoding)")
            return
        }
        self.sourceEncoding = validEncoding
        if let content {
            registerContentChangeUndo(fileURL: fileURL, nsString: nsString, content: content)
            content.mutableString.setString(nsString as String)
        } else {
            self.content = NSTextStorage(string: nsString as String)
        }
        NotificationCenter.default.post(name: Self.didOpenNotification, object: self)
    }

    /// If this file is already open and being tracked by an undo manager, we register an undo mutation
    /// of the entire contents. This allows the user to undo changes that occurred outside of CodeEdit
    /// while the file was displayed in CodeEdit.
    ///
    /// - Note: This is inefficient memory-wise. We could do a diff of the file and only register the
    ///         mutations that would recreate the diff. However, that would instead be CPU intensive.
    ///         Tradeoffs.
    private func registerContentChangeUndo(fileURL: URL?, nsString: NSString, content: NSTextStorage) {
        guard let fileURL else { return }
        // If there's an undo manager, register a mutation replacing the entire contents.
        let mutation = TextMutation(
            string: nsString as String,
            range: NSRange(location: 0, length: content.length),
            limit: content.length
        )
        let undoManager = self.findWorkspace()?.undoRegistration.managerIfExists(forFile: fileURL)
        undoManager?.registerMutation(mutation)
    }

    // MARK: - Autosave

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

    /// If ``hasUnautosavedChanges`` is `true` and an autosave has not already been scheduled, schedules a new autosave.
    /// If ``hasUnautosavedChanges`` is `false`, cancels any scheduled timers and returns.
    ///
    /// All operations are done with the ``autosaveTimerLock`` acquired (including the scheduled autosave) to ensure
    /// correct timing when scheduling or cancelling timers.
    override func scheduleAutosaving() {
        autosaveTimerLock.withLock {
            if self.hasUnautosavedChanges {
                guard autosaveTimer == nil else { return }
                autosaveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
                    self?.autosaveTimerLock.withLock {
                        guard timer.isValid else { return }
                        self?.autosaveTimer = nil
                        self?.autosave(withDelegate: nil, didAutosave: nil, contextInfo: nil)
                    }
                }
            } else {
                autosaveTimer?.invalidate()
                autosaveTimer = nil
            }
        }
    }

    // MARK: - External Changes

    /// Handle the notification that the represented file item changed.
    ///
    /// We check if a file has been modified and can be read again to display to the user.
    /// To determine if a file has changed, we check the modification date. If it's different from the stored one,
    /// we continue.
    /// To determine if we can reload the file, we check if the document has outstanding edits. If not, we reload the
    /// file.
    override func presentedItemDidChange() {
        if fileModificationDate != getModificationDate() {
            guard isDocumentEdited else {
                fileModificationDate = getModificationDate()
                if let fileURL, let fileType {
                    // This blocks the presented item thread intentionally. If we don't wait, we'll receive more updates
                    // that the file has changed and we'll end up dispatching multiple reads.
                    // The presented item thread expects this operation to by synchronous anyways.

                    // https://github.com/CodeEditApp/CodeEdit/issues/2091
                    // We can't use `.asyncAndWait` on Ventura as it seems the symbol is missing on that platform.
                    // Could be just for x86 machines.
                    DispatchQueue.main.sync {
                        try? self.read(from: fileURL, ofType: fileType)
                    }
                }
                return
            }
        }

        super.presentedItemDidChange()
    }

    /// Helper to find the last modified date of the represented file item.
    /// 
    /// Different from `NSDocument.fileModificationDate`. This returns the *current* modification date, whereas the
    /// alternative stores the date that existed when we last read the file.
    private func getModificationDate() -> Date? {
        guard let path = fileURL?.absolutePath else { return nil }
        return try? FileManager.default.attributesOfItem(atPath: path)[.modificationDate] as? Date
    }

    // MARK: - Close

    override func close() {
        super.close()
        NotificationCenter.default.post(name: Self.didCloseNotification, object: fileURL)
    }

    override func save(_ sender: Any?) {
        guard let fileURL else {
            super.save(sender)
            return
        }

        do {
            // Get parent directory for cases when entire folders were deleted – and recreate them as needed
            let directory = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)

            super.save(sender)
        } catch {
            presentError(error)
        }
    }

    override func fileNameExtension(
        forType typeName: String,
        saveOperation: NSDocument.SaveOperationType
    ) -> String? {
        guard let fileTypeName = Self.fileTypeExtension[typeName] else {
            return super.fileNameExtension(forType: typeName, saveOperation: saveOperation)
        }
        return fileTypeName
    }

    /// Determines the code language of the document.
    /// Use ``CodeFileDocument/language`` for the default value before using this. That property is used to override
    /// the file's language.
    /// - Returns: The detected code language.
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

// MARK: LanguageServerDocument

extension CodeFileDocument: LanguageServerDocument {
    /// A stable string to use when identifying documents with language servers.
    /// Needs to be a valid URI, so always returns with the `file://` prefix to indicate it's a file URI.
    var languageServerURI: String? {
        fileURL?.lspURI
    }
}

private extension CodeFileDocument {

    static let fileTypeExtension: [String: String?] = [
        "public.make-source": nil
    ]
}
