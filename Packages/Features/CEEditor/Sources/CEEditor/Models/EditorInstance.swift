//
//  EditorInstance.swift
//  CodeEdit
//
//  Created by Khan Winter on 1/4/24.
//

import Foundation
import CodeEditCore
import AppKit
import Combine
import CodeEditTextView
import CodeEditSourceEditor

/// A single instance of an editor in a group with a published ``EditorInstance/cursorPositions`` variable to publish
/// the user's current location in a file.
public class EditorInstance: ObservableObject, Hashable {
    /// The file presented in this editor instance.
    public let file: CEWorkspaceFile

    /// A publisher for the user's current location in a file.
    @Published public var cursorPositions: [CursorPosition]
    @Published public var scrollPosition: CGPoint?

    @Published public var findText: String?
    public var findTextSubject: PassthroughSubject<String?, Never>

    @Published public var replaceText: String?
    public var replaceTextSubject: PassthroughSubject<String?, Never>

    public var rangeTranslator: RangeTranslator = RangeTranslator()

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init

    public init(findReplaceQuery: FindReplaceQuery?, file: CEWorkspaceFile, cursorPositions: [CursorPosition]? = nil) {
        self.file = file
        let url = file.url
        let editorState = EditorStateRestoration.shared?.restorationState(for: url)

        findText = findReplaceQuery?.searchQuery
        findTextSubject = PassthroughSubject()
        replaceText = findReplaceQuery?.replaceText
        replaceTextSubject = PassthroughSubject()

        self.cursorPositions = (
            cursorPositions ?? editorState?.editorCursorPositions ?? [CursorPosition(line: 1, column: 1)]
        )
        self.scrollPosition = editorState?.scrollPosition

        // Setup listeners

        Publishers.CombineLatest(
            $cursorPositions.removeDuplicates(),
            $scrollPosition
                .debounce(for: .seconds(0.1), scheduler: RunLoop.main) // This can trigger *very* often
                .removeDuplicates()
        )
        .sink { (cursorPositions, scrollPosition) in
            EditorStateRestoration.shared?.updateRestorationState(
                for: url,
                data: .init(cursorPositions: cursorPositions, scrollPosition: scrollPosition ?? .zero)
            )
        }
        .store(in: &cancellables)

        listenToFindText(findReplaceQuery: findReplaceQuery)
        listenToReplaceText(findReplaceQuery: findReplaceQuery)
    }

    // MARK: - Find/Replace Listeners

    func listenToFindText(findReplaceQuery: FindReplaceQuery?) {
        findReplaceQuery?.$searchQuery
            .receive(on: RunLoop.main)
            .sink { [weak self] newQuery in
                if self?.findText != newQuery {
                    self?.findText = newQuery
                }
            }
            .store(in: &cancellables)
        findTextSubject
            .receive(on: RunLoop.main)
            .sink { [weak findReplaceQuery, weak self] newFindText in
                if let newFindText, findReplaceQuery?.searchQuery != newFindText {
                    findReplaceQuery?.searchQuery = newFindText
                }
                self?.findText = findReplaceQuery?.searchQuery
            }
            .store(in: &cancellables)
    }

    func listenToReplaceText(findReplaceQuery: FindReplaceQuery?) {
        findReplaceQuery?.$replaceText
            .receive(on: RunLoop.main)
            .sink { [weak self] newText in
                if self?.replaceText != newText {
                    self?.replaceText = newText
                }
            }
            .store(in: &cancellables)
        replaceTextSubject
            .receive(on: RunLoop.main)
            .sink { [weak findReplaceQuery, weak self] newReplaceText in
                if let newReplaceText, findReplaceQuery?.replaceText != newReplaceText {
                    findReplaceQuery?.replaceText = newReplaceText
                }
                self?.replaceText = findReplaceQuery?.replaceText
            }
            .store(in: &cancellables)
    }

    // MARK: - Hashable, Equatable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(file)
    }

    public static func == (lhs: EditorInstance, rhs: EditorInstance) -> Bool {
        lhs.file == rhs.file
    }

    // MARK: - RangeTranslator

    /// Translates ranges (eg: from a cursor position) to other information like the number of lines in a range.
    public class RangeTranslator: TextViewCoordinator {
        private weak var textViewController: TextViewController?

        init() { }

        public func prepareCoordinator(controller: TextViewController) {
            self.textViewController = controller
        }

        public func controllerDidAppear(controller: TextViewController) {
            if controller.isEditable && controller.isSelectable {
                controller.view.window?.makeFirstResponder(controller.textView)
            }
        }

        public func destroy() {
            self.textViewController = nil
        }

        /// Returns the lines contained in the given range.
        /// - Parameter range: The range to use.
        /// - Returns: The number of lines contained by the given range. Or `0` if the text view could not be found,
        ///            or lines could not be found for the given range.
        public func linesInRange(_ range: NSRange) -> Int {
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

        public func moveLinesUp() {
            guard let controller = textViewController else { return }
            controller.moveLinesUp()
        }

        public func moveLinesDown() {
            guard let controller = textViewController else { return }
            controller.moveLinesDown()
        }
    }
}
