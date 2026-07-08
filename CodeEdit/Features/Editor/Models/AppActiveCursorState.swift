//
//  AppActiveCursorState.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import Combine
import CodeEditCore
import CodeEditSourceEditor

/// App-side `ActiveCursorState` over a window's `EditorManager`. Publishes the
/// active editor's cursor positions across both active-editor switches and
/// within-editor tab changes, and forwards `linesInRange(_:)` to the live
/// `EditorInstance.rangeTranslator`.
final class AppActiveCursorState: ActiveCursorState {
    private let subject: CurrentValueSubject<[EditorCursorPosition], Never>
    private weak var currentTab: EditorInstance?
    private var editorCancellable: AnyCancellable?
    private var cursorCancellable: AnyCancellable?

    @MainActor
    init(editorManager: EditorManager) {
        let initialTab = editorManager.activeEditor.selectedTab
        currentTab = initialTab
        subject = CurrentValueSubject(Self.map(initialTab?.cursorPositions ?? []))

        editorCancellable = editorManager.$activeEditor
            .flatMap { $0.$selectedTab }
            .sink { [weak self] tab in
                self?.bind(to: tab)
            }
    }

    @MainActor
    private func bind(to tab: EditorInstance?) {
        currentTab = tab
        guard let tab else {
            cursorCancellable = nil
            subject.send([])
            return
        }
        cursorCancellable = tab.$cursorPositions
            .sink { [weak subject] positions in
                subject?.send(Self.map(positions))
            }
    }

    private static func map(_ positions: [CursorPosition]) -> [EditorCursorPosition] {
        positions.map { EditorCursorPosition(line: $0.start.line, column: $0.start.column, range: $0.range) }
    }

    var cursorPositions: [EditorCursorPosition] { subject.value }

    var cursorPositionsPublisher: AnyPublisher<[EditorCursorPosition], Never> {
        subject.eraseToAnyPublisher()
    }

    func linesInRange(_ range: NSRange) -> Int {
        currentTab?.rangeTranslator.linesInRange(range) ?? 0
    }
}
