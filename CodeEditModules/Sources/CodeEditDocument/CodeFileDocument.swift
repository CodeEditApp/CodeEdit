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
import CodeEditCore
import Combine
import OSLog
import TextStory

enum CodeFileError: Error {
    case failedToDecode
    case failedToEncode
    case fileTypeError
}

@objc(CodeFileDocument)
public final class CodeFileDocument: NSDocument, ObservableObject {
    public struct OpenOptions {
        public let cursorPositions: [CursorPosition]

        public init(cursorPositions: [CursorPosition]) {
            self.cursorPositions = cursorPositions
        }
    }

    /// `nonisolated` so the nonisolated overrides can log; `Logger` is `Sendable`.
    nonisolated static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "CodeFileDocument")

    /// Vends the app-registered delegate (see ``CodeFileDocumentDelegate``). A static provider —
    /// not a per-instance property — because framework-created documents fire `documentDidOpen`
    /// from `read()` during `init(contentsOf:)`, before any caller could set an instance property.
    /// Wired by the app at launch (like ``isAutoSaveOnProvider``); defaults to `nil` so tests and
    /// previews are safe. Call sites handle main-actor hops themselves.
    nonisolated(unsafe) public static var delegateProvider: () -> CodeFileDocumentDelegate? = { nil }

    /// The app-registered delegate. Provides LSP lifecycle notifications, the standalone-window
    /// content view, and undo-manager lookup, keeping this document free of app-tier types.
    /// `nil` when unhosted (e.g. tests that don't wire a provider).
    private var delegate: CodeFileDocumentDelegate? { Self.delegateProvider() }

    /// The text content of the document, stored as a text storage
    ///
    /// This is intentionally not a `@Published` variable. If it were published, SwiftUI would do a string
    /// compare each time the contents are updated, which could cause a hang on each keystroke if the file is large
    /// enough.
    ///
    /// To receive notifications for content updates, subscribe to one of the publishers on ``contentCoordinator``.
    public var content: NSTextStorage?

    /// The string encoding of the original file. Used to save the file back to the encoding it was loaded from.
    public var sourceEncoding: FileEncoding?

    /// The coordinator to use to subscribe to edit events and cursor location events.
    /// See ``CodeEditSourceEditor/CombineCoordinator``.
    @Published public var contentCoordinator: CombineCoordinator = CombineCoordinator()

    /// Used to override detected languages.
    @Published public var language: CodeLanguage?

    /// Document-specific overridden indent option.
    @Published public var indentOption: CodeEditCore.IndentOption?

    /// Document-specific overridden tab width.
    @Published public var defaultTabWidth: Int?

    /// Document-specific overridden line wrap preference.
    @Published public var wrapLines: Bool?

    /// The type of data this file document contains.
    ///
    /// If its text content is not nil, a `text` UTType is returned.
    ///
    /// - Note: The UTType doesn't necessarily mean the file extension, it can be the MIME
    /// type or any other form of data representation.
    public var utType: UTType? {
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
    public var openOptions: OpenOptions?

    private let isDocumentEditedSubject = PassthroughSubject<Bool, Never>()

    /// Publisher for isDocumentEdited property
    public var isDocumentEditedPublisher: AnyPublisher<Bool, Never> {
        isDocumentEditedSubject.eraseToAnyPublisher()
    }

    /// A lock that ensures autosave scheduling happens correctly.
    /// `nonisolated` for the nonisolated `scheduleAutosaving()` override; `NSLock` is `Sendable`.
    nonisolated private let autosaveTimerLock: NSLock = NSLock()

    /// Timer used to schedule autosave intervals.
    /// `nonisolated(unsafe)` because every access happens with ``autosaveTimerLock`` held — the
    /// lock is the synchronisation, which the compiler cannot see. Never touch this outside it.
    nonisolated(unsafe) private var autosaveTimer: Timer?

    /// Provides the current "autosave enabled" preference without coupling this type to the
    /// Settings feature. Wired by the app at launch (see `AppDelegate`). Defaults to `false`
    /// so the type stays self-contained for packaging and predictable in tests that don't wire it.
    nonisolated(unsafe) public static var isAutoSaveOnProvider: () -> Bool = { false }

    // MARK: - NSDocument

    override public static var autosavesInPlace: Bool {
        isAutoSaveOnProvider()
    }

    override public var autosavingFileType: String? {
        Self.isAutoSaveOnProvider() ? fileType : nil
    }

    override public func makeWindowControllers() {
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

        if let delegate {
            window.contentView = delegate.makeWindowContentView(for: self)
        }

        window.makeKeyAndOrderFront(nil)

        if let fileURL, UserDefaults.standard.object(forKey: "NSWindow Frame \(fileURL.path)") == nil {
            window.center()
        }
    }

    // MARK: - Data

    override public func data(ofType _: String) throws -> Data {
        guard let sourceEncoding, let data = (content?.string as NSString?)?.data(using: sourceEncoding.nsValue) else {
            Self.logger.error("Failed to encode contents to \(self.sourceEncoding.debugDescription)")
            throw CodeFileError.failedToEncode
        }
        return data
    }

    // MARK: - Read

    /// Never read concurrently.
    ///
    /// This is AppKit's default, stated explicitly because ``read(from:ofType:)`` depends on it:
    /// that method overrides a nonisolated `NSDocument` entry point but touches this document's
    /// main-actor state, which is only sound while reads stay on the main thread. Returning `true`
    /// here would make that unsound with no compile-time error.
    override public static func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        false
    }

    /// This function is used for decoding files.
    /// It should not throw error as unsupported files can still be opened by QLPreviewView.
    override public func read(from data: Data, ofType _: String) throws {
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
        // `read(from:ofType:)` overrides a nonisolated `NSDocument` method, but everything below
        // touches main-actor state. Reads are main-thread only, which
        // `canConcurrentlyReadDocuments(ofType:)` above pins, so stating the isolation is sound.
        let text = nsString as String
        MainActor.assumeIsolated {
            self.sourceEncoding = validEncoding
            if let content {
                registerContentChangeUndo(fileURL: fileURL, text: text, content: content)
                content.mutableString.setString(text)
            } else {
                self.content = NSTextStorage(string: text)
            }
            notifyLSPDidOpen()
        }
    }

    /// The delegate is main-actor isolated, but document reads and closes can happen off the main
    /// thread (AppKit concurrent reads, Swift Testing). Mirrors the NotificationCenter `queue: .main`
    /// delivery this replaced: synchronous on main, async hop otherwise.
    private func notifyLSPDidOpen() {
        if Thread.isMainThread {
            MainActor.assumeIsolated { delegate?.documentDidOpen(self) }
        } else {
            DispatchQueue.main.async { self.delegate?.documentDidOpen(self) }
        }
    }

    private func notifyLSPDidClose(_ url: URL) {
        if Thread.isMainThread {
            MainActor.assumeIsolated { delegate?.documentDidClose(at: url) }
        } else {
            DispatchQueue.main.async { self.delegate?.documentDidClose(at: url) }
        }
    }

    /// If this file is already open and being tracked by an undo manager, we register an undo mutation
    /// of the entire contents. This allows the user to undo changes that occurred outside of CodeEdit
    /// while the file was displayed in CodeEdit.
    ///
    /// - Note: This is inefficient memory-wise. We could do a diff of the file and only register the
    ///         mutations that would recreate the diff. However, that would instead be CPU intensive.
    ///         Tradeoffs.
    nonisolated private func registerContentChangeUndo(fileURL: URL?, text: String, content: NSTextStorage) {
        guard let fileURL else { return }
        // The delegate's undo registry is main-actor isolated. Capture only Sendable primitives and build
        // the (non-Sendable) `TextMutation` on the main actor so nothing non-Sendable crosses the boundary.
        // Re-reads reach here on the main thread; mirror the `queue: .main` bridge used for LSP notifications.
        let string = text
        let length = content.length
        let register: @MainActor () -> Void = { [weak self] in
            let mutation = TextMutation(
                string: string,
                range: NSRange(location: 0, length: length),
                limit: length
            )
            self?.delegate?.undoManager(forFile: fileURL)?.registerMutation(mutation)
        }
        if Thread.isMainThread {
            MainActor.assumeIsolated { register() }
        } else {
            DispatchQueue.main.async { register() }
        }
    }

    // MARK: - Autosave

    /// Triggered when change occurred
    override public func updateChangeCount(_ change: NSDocument.ChangeType) {
        super.updateChangeCount(change)

        if CodeFileDocument.autosavesInPlace {
            return
        }

        self.isDocumentEditedSubject.send(self.isDocumentEdited)
    }

    /// Triggered when changes saved
    override public func updateChangeCount(
        withToken changeCountToken: Any,
        for saveOperation: NSDocument.SaveOperationType
    ) {
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
    override public func scheduleAutosaving() {
        autosaveTimerLock.withLock {
            if self.hasUnautosavedChanges {
                guard autosaveTimer == nil else { return }
                autosaveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
                    // Bound once, rather than optional-chained per access: the isolation below
                    // cannot state itself for a value the escaping timer block still shares.
                    guard let document = self else { return }
                    document.autosaveTimerLock.withLock {
                        guard timer.isValid else { return }
                        document.autosaveTimer = nil
                        // Delivered on the main runloop the timer was scheduled on; assert that
                        // rather than hopping, which would fire outside the lock.
                        MainActor.assumeIsolated {
                            document.autosave(withDelegate: nil, didAutosave: nil, contextInfo: nil)
                        }
                    }
                }
            } else {
                autosaveTimer?.invalidate()
                autosaveTimer = nil
            }
        }
    }

    // MARK: - Close

    override public func close() {
        super.close()
        if let fileURL {
            notifyLSPDidClose(fileURL)
        }
    }

    override public func save(_ sender: Any?) {
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

    override public func fileNameExtension(
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
    public func getLanguage() -> CodeLanguage {
        guard let url = fileURL else {
            return .default
        }
        return language ?? CodeLanguage.detectLanguageFrom(
            url: url,
            prefixBuffer: content?.string.getFirstLines(5),
            suffixBuffer: content?.string.getLastLines(5)
        )
    }

}

private extension CodeFileDocument {

    /// `nonisolated` so `fileNameExtension(forType:saveOperation:)` can read it off the main actor.
    /// `[String: String?]` is `Sendable`, so this is safe rather than merely asserted.
    nonisolated static let fileTypeExtension: [String: String?] = [
        "public.make-source": nil
    ]
}
