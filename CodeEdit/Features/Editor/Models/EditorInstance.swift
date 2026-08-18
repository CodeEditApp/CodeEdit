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
    private static let defaultCursorPositions = [CursorPosition(line: 1, column: 1)]

    /// The file presented in this editor instance.
    let file: CEWorkspaceFile

    /// A publisher for the user's current location in a file.
    @Published var cursorPositions: [CursorPosition]
    @Published var scrollPosition: CGPoint?

    @Published var findText: String?
    var findTextSubject: PassthroughSubject<String?, Never>

    @Published var replaceText: String?
    var replaceTextSubject: PassthroughSubject<String?, Never>

    var rangeTranslator: RangeTranslator = RangeTranslator()

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init

    init(workspace: WorkspaceDocument?, file: CEWorkspaceFile, cursorPositions: [CursorPosition]? = nil) {
        self.file = file
        let url = file.url
        let editorState = EditorStateRestoration.shared?.restorationState(for: url)

        findText = workspace?.searchState?.searchQuery
        findTextSubject = PassthroughSubject()
        replaceText = workspace?.searchState?.replaceText
        replaceTextSubject = PassthroughSubject()

        // Prefer an explicit position, then a non-empty restored position, else a caret at 1:1.
        // Empty restored arrays must not wipe the default — the status bar would show nothing.
        let restoredCursorPositions = editorState?.editorCursorPositions
        self.cursorPositions = cursorPositions
            ?? (restoredCursorPositions?.isEmpty == false ? restoredCursorPositions : nil)
            ?? Self.defaultCursorPositions
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

        listenToFindText(workspace: workspace)
        listenToReplaceText(workspace: workspace)
    }

    // MARK: - Find/Replace Listeners

    func listenToFindText(workspace: WorkspaceDocument?) {
        workspace?.searchState?.$searchQuery
            .receive(on: RunLoop.main)
            .sink { [weak self] newQuery in
                if self?.findText != newQuery {
                    self?.findText = newQuery
                }
            }
            .store(in: &cancellables)
        findTextSubject
            .receive(on: RunLoop.main)
            .sink { [weak workspace, weak self] newFindText in
                if let newFindText, workspace?.searchState?.searchQuery != newFindText {
                    workspace?.searchState?.searchQuery = newFindText
                }
                self?.findText = workspace?.searchState?.searchQuery
            }
            .store(in: &cancellables)
    }

    func listenToReplaceText(workspace: WorkspaceDocument?) {
        workspace?.searchState?.$replaceText
            .receive(on: RunLoop.main)
            .sink { [weak self] newText in
                if self?.replaceText != newText {
                    self?.replaceText = newText
                }
            }
            .store(in: &cancellables)
        replaceTextSubject
            .receive(on: RunLoop.main)
            .sink { [weak workspace, weak self] newReplaceText in
                if let newReplaceText, workspace?.searchState?.replaceText != newReplaceText {
                    workspace?.searchState?.replaceText = newReplaceText
                }
                self?.replaceText = workspace?.searchState?.replaceText
            }
            .store(in: &cancellables)
    }

    // MARK: - Hashable, Equatable

    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
    }

    static func == (lhs: EditorInstance, rhs: EditorInstance) -> Bool {
        lhs.file == rhs.file
    }

    // MARK: - RangeTranslator

    /// Translates ranges (eg: from a cursor position) to other information like the number of lines in a range.
    class RangeTranslator: TextViewCoordinator {
        /// Emits when the text view controller becomes visible so observers can refresh resolved cursor labels.
        let controllerDidAppearSubject = PassthroughSubject<Void, Never>()

        private weak var textViewController: TextViewController?

        init() { }

        func prepareCoordinator(controller: TextViewController) {
            self.textViewController = controller
        }

        func controllerDidAppear(controller: TextViewController) {
            if controller.isEditable && controller.isSelectable {
                controller.view.window?.makeFirstResponder(controller.textView)
            }
            controllerDidAppearSubject.send()
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

        /// Resolves a cursor position through the text view when available; otherwise returns the input unchanged.
        func resolveCursorPosition(_ cursorPosition: CursorPosition) -> CursorPosition {
            textViewController?.resolveCursorPosition(cursorPosition) ?? cursorPosition
        }

        func moveLinesUp() {
            guard let controller = textViewController else { return }
            controller.moveLinesUp()
        }

        func moveLinesDown() {
            guard let controller = textViewController else { return }
            controller.moveLinesDown()
        }
    }
}
