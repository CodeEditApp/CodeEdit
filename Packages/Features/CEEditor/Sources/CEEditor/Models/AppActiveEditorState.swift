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
public final class AppActiveEditorState: ActiveEditorState {
    private let subject: CurrentValueSubject<CEWorkspaceFile?, Never>
    private var cancellable: AnyCancellable?

    @MainActor
    public init(editorManager: EditorManager) {
        subject = CurrentValueSubject(editorManager.activeEditor.selectedTab?.file)
        cancellable = editorManager.$activeEditor
            .flatMap { $0.$selectedTab }
            .map { $0?.file }
            .sink { [weak subject] file in subject?.send(file) }
    }

    public var selectedFile: CEWorkspaceFile? { subject.value }
    public var selectedFilePublisher: AnyPublisher<CEWorkspaceFile?, Never> { subject.eraseToAnyPublisher() }
}
