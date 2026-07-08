//
//  AppFileRelocator.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import CodeEditCore
import CEWorkspaceFileManager
import Factory

/// App-shell binding of the `FileRelocator` command. Resolves the workspace that
/// owns the file and delegates to `MoveFileUseCase`, which moves the file and
/// reconciles open tabs.
final class AppFileRelocator: FileRelocator {
    private let windowManager: WorkspaceWindowManaging

    init(windowManager: WorkspaceWindowManaging = Container.shared.workspaceWindowManager()) {
        self.windowManager = windowManager
    }

    @MainActor
    func relocate(file: CEWorkspaceFile, to destination: URL) throws -> CEWorkspaceFile? {
        guard let workspace = windowManager.workspace(containing: file.url) else { return nil }
        return try MoveFileUseCase().execute(file: file, to: destination, in: workspace)
    }
}
