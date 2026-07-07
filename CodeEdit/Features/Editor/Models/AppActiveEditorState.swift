//
//  AppActiveEditorState.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import Combine
import CodeEditCore
import CEWorkspaceFileManager

/// App-side `ActiveEditorState` over a window's `EditorManager`. Emits the active editor's
/// selected file across both active-editor switches and within-editor tab changes.
final class AppActiveEditorState: ActiveEditorState {
    private let subject: CurrentValueSubject<CEWorkspaceFile?, Never>
    private var cancellable: AnyCancellable?

    @MainActor
    init(editorManager: EditorManager) {
        subject = CurrentValueSubject(editorManager.activeEditor.selectedTab?.file)
        cancellable = editorManager.$activeEditor
            .flatMap { $0.$selectedTab }
            .map { $0?.file }
            .sink { [weak subject] file in subject?.send(file) }
    }

    var selectedFile: CEWorkspaceFile? { subject.value }
    var selectedFilePublisher: AnyPublisher<CEWorkspaceFile?, Never> { subject.eraseToAnyPublisher() }
}
