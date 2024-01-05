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
class EditorInstance: Hashable {
    // Public

    /// The file presented in this editor instance.
    let file: CEWorkspaceFile

    /// A publisher for the user's current location in a file.
    var cursorPositions: AnyPublisher<[CursorPosition], Never> {
        cursorSubject.eraseToAnyPublisher()
    }

    // Public TextViewCoordinator APIs

    var rangeTranslator: RangeTranslator?

    // Internal Combine subjects

    private let cursorSubject = CurrentValueSubject<[CursorPosition], Never>([])

    // MARK: - Init, Hashable, Equatable

    init(file: CEWorkspaceFile, cursorPositions: [CursorPosition] = []) {
        self.file = file
        self.cursorSubject.send(cursorPositions)
        self.rangeTranslator = RangeTranslator(cursorSubject: cursorSubject)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
    }

    static func == (lhs: EditorInstance, rhs: EditorInstance) -> Bool {
        lhs.file == rhs.file
    }

    // MARK: - RangeTranslator

    /// Translates ranges (eg: from a cursor position) to other information like the number of lines in a range.
    class RangeTranslator: TextViewCoordinator {
        private weak var textViewController: TextViewController?
        private var cursorSubject: CurrentValueSubject<[CursorPosition], Never>

        init(cursorSubject: CurrentValueSubject<[CursorPosition], Never>) {
            self.cursorSubject = cursorSubject
        }

        func textViewDidChangeSelection(controller: TextViewController, newPositions: [CursorPosition]) {
            self.cursorSubject.send(controller.cursorPositions)
        }

        func prepareCoordinator(controller: TextViewController) {
            self.textViewController = controller
            self.cursorSubject.send(controller.cursorPositions)
        }

        func destroy() {
            self.textViewController = nil
        }

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
    }
}
