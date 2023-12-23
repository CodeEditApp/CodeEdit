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
final class CodeFileDocument: NSDocument, ObservableObject, QLPreviewItem {

    @Published var content = ""

    /// Used to override detected languages.
    @Published var language: CodeLanguage?

    /// Document-specific overriden indent option.
    @Published var indentOption: SettingsData.TextEditingSettings.IndentOption?

    /// Document-specific overriden tab width.
    @Published var defaultTabWidth: Int?

    /// Document-specific overriden line wrap preference.
    @Published var wrapLines: Bool?

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

    @Published var cursorPositions = [CursorPosition]()

    var rangeTranslator: RangeTranslator = RangeTranslator()

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
        guard let content = String(data: data, encoding: .utf8) else { return }
        self.content = content
    }

    /// Triggered when change occured
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

    class RangeTranslator: TextViewCoordinator {
        private weak var textViewController: TextViewController?

        /// Returns the lines contained in the given range.
        /// - Parameter range: The range to use.
        /// - Returns: The number of lines contained by the given range. Or `0` if the text view could not be found,
        ///            or lines could not be found for the given range.
        func linesInRange(_ range: NSRange) -> Int {
            // TODO: textView should be public, workaround for now
            guard let controller = textViewController,
                  let scrollView = controller.view as? NSScrollView,
                  let textView = scrollView.documentView as? TextView,
                  // Find the lines at the beginning and end of the range
                  let startTextLine = textView.layoutManager.textLineForOffset(range.location),
                  let endTextLine = textView.layoutManager.textLineForOffset(range.upperBound) else {
                return 0
            }
            return (endTextLine.index - startTextLine.index) + 1
        }

        func prepareCoordinator(controller: TextViewController) {
            self.textViewController = controller
        }

        func destroy() {
            self.textViewController = nil
        }
    }
}
