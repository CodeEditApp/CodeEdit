//
//  AppFileRelocator.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import CodeEditCore
import CEWorkspaceFileManager

/// App-shell binding of the `FileRelocator` command. Resolves the workspace that
/// owns the file and delegates to `FileMover`, which moves the file and
/// reconciles open tabs.
final class AppFileRelocator: FileRelocator {
    private let windowManager: WorkspaceWindowManaging

    init(windowManager: WorkspaceWindowManaging) {
        self.windowManager = windowManager
    }

    @MainActor
    func relocate(file: CEWorkspaceFile, to destination: URL) throws -> CEWorkspaceFile? {
        guard let workspace = windowManager.workspace(containing: file.url) else { return nil }
        return try FileMover().execute(file: file, to: destination, in: workspace)
    }
}
