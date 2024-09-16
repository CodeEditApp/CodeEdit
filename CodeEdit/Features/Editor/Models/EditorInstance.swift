//
//  EditorInstance.swift
//  CodeEdit
//
//  Created by Khan Winter on 1/4/24.
//

import Foundation
import AppKit
import Combine
import CodeEditTextView
import CodeEditSourceEditor

/// A single instance of an editor in a group with a published ``EditorInstance/cursorPositions`` variable to publish
/// the user's current location in a file.
///
/// Use this object instead of a `CEWorkspaceFile` or `CodeFileDocument` when something related to *one* editor needs
/// to happen. For instance, storing the current cursor positions for a single editor.
class EditorInstance: Hashable, ObservableObject {

    /// The file presented in this editor instance. This is not unique.
    let file: CEWorkspaceFile

    @Published var cursorPositions: [CursorPosition]

    lazy var rangeTranslator: RangeTranslator = {
        RangeTranslator(parent: self)
    }()

    // MARK: - Init, Hashable, Equatable

    init(file: CEWorkspaceFile, cursorPositions: [CursorPosition] = []) {
        self.file = file
        self.cursorPositions = cursorPositions
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
        hasher.combine(cursorPositions)
    }

    static func == (lhs: EditorInstance, rhs: EditorInstance) -> Bool {
        lhs.file == rhs.file && lhs.cursorPositions == rhs.cursorPositions
    }

    // MARK: - RangeTranslator

    /// Translates ranges (eg: from a cursor position) to other information like the number of lines in a range.
    class RangeTranslator: TextViewCoordinator {
        private weak var textViewController: TextViewController?
        private weak var editorInstance: EditorInstance?

        fileprivate init(parent: EditorInstance) {
            self.editorInstance = parent
        }

        func prepareCoordinator(controller: TextViewController) {
            self.textViewController = controller
            self.editorInstance?.cursorPositions = controller.cursorPositions
        }

        func textViewDidChangeSelection(controller: TextViewController, newPositions: [CursorPosition]) {
            self.editorInstance?.cursorPositions = newPositions
        }

        func destroy() {
            self.textViewController = nil
        }

        /// Returns the lines contained in the given range.
        /// - Parameter range: The range to use.
        /// - Returns: The number of lines contained by the given range. Or `0` if the text view could not be found,
        ///            or lines could not be found for the given range.
        func linesInRange(_ range: NSRange) -> Int {
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
    }
}
