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
class EditorInstance: ObservableObject, Hashable {
    let file: CEWorkspaceFile
    @Published var cursorPositions: [CursorPosition]

    public var rangeTranslator: RangeTranslator?

    init(file: CEWorkspaceFile, cursorPositions: [CursorPosition] = []) {
        self.file = file
        self.cursorPositions = cursorPositions
        self.rangeTranslator = RangeTranslator(cursorPositions: $cursorPositions.eraseToAnyPublisher())
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
    }

    static func == (lhs: EditorInstance, rhs: EditorInstance) -> Bool {
        lhs.file == rhs.file
    }

    class RangeTranslator: TextViewCoordinator {
        private weak var textViewController: TextViewController?
        private var cursorPositions: AnyPublisher<[CursorPosition], Never>

        init(cursorPositions: AnyPublisher<[CursorPosition], Never>) {
            self.cursorPositions = cursorPositions
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

        func prepareCoordinator(controller: TextViewController) {
            self.textViewController = controller
        }

        func destroy() {
            self.textViewController = nil
        }
    }
}
