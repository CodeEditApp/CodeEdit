//
//  FileDropHandler.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 15/04/26.
//

import Foundation
import CEWorkspaceFileManager
import CodeEditCore

/// Resolves dropped file URLs into copy/move operations, handling source resolution and replace conflicts.
@MainActor
final class FileDropHandler {

    struct Operation {
        let source: CEWorkspaceFile
        let destination: URL
        let isCopy: Bool
    }

    /// Returns the operations that should be executed for the given dropped URLs.
    /// Filters out drops onto self/parent. Asks `confirmReplace` (and removes the existing file)
    /// when the destination already exists.
    func execute(
        urls: [URL],
        destinationParent: CEWorkspaceFile,
        isCopyOperation: Bool,
        in workspace: Workspace,
        confirmReplace: (String) -> Bool
    ) throws -> [Operation] {
        let destParentURL = destinationParent.url
        var operations: [Operation] = []

        for url in urls {
            let destURL = destParentURL.appending(path: url.lastPathComponent)

            // Cancel dropping a file on itself or in its own parent directory
            if url == destURL || url == destParentURL {
                continue
            }

            // Resolve the source: either an existing workspace file, or treat as external
            let source = workspace.workspaceFileManager.getFile(url.path)
                ?? CEWorkspaceFile(url: URL(fileURLWithPath: url.path))

            // Handle existing destination via the supplied confirmation closure
            if CEWorkspaceFile.fileManager.fileExists(atPath: destURL.path) {
                guard confirmReplace(url.lastPathComponent) else {
                    continue
                }
                try CEWorkspaceFile.fileManager.removeItem(at: destURL)
            }

            operations.append(Operation(source: source, destination: destURL, isCopy: isCopyOperation))
        }

        return operations
    }
}
