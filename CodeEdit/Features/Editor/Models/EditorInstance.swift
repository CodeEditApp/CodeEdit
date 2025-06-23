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
    /// The file presented in this editor instance.
    let file: CEWorkspaceFile

    /// A publisher for the user's current location in a file.
    @Published var cursorPositions: [CursorPosition] = []
    @Published var scrollPosition: CGPoint?
    @Published var findText: String?

    var rangeTranslator: RangeTranslator = RangeTranslator()

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init, Hashable, Equatable

    init(file: CEWorkspaceFile, cursorPositions: [CursorPosition]? = nil) {
        self.file = file
        let url = file.url
        let editorState = EditorStateRestoration.shared?.restorationState(for: url)

        self.cursorPositions = cursorPositions ?? editorState?.editorCursorPositions ?? []
        self.scrollPosition = editorState?.scrollPosition

        // Setup listeners

        Publishers.CombineLatest(
            $cursorPositions.removeDuplicates(),
            $scrollPosition
                .debounce(for: .seconds(0.5), scheduler: RunLoop.main) // This can trigger *very* often
                .removeDuplicates()
        )
        .sink { (cursorPositions, scrollPosition) in
            EditorStateRestoration.shared?.updateRestorationState(
                for: url,
                data: .init(cursorPositions: cursorPositions, scrollPosition: scrollPosition ?? .zero)
            )
        }
        .store(in: &cancellables)
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

        init() { }

        func prepareCoordinator(controller: TextViewController) {
            self.textViewController = controller
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
