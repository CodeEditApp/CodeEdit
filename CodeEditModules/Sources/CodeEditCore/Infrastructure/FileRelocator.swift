//
//  FileRelocator.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom.
//

import Foundation

/// Command to move a file within its workspace and reconcile open editor tabs
/// (close tabs for the old location, reopen at the new one). Lets the File
/// Inspector rename/relocate without depending on the Editor feature or holding
/// a `Workspace`. Returns the resolved new file (nil for folders or unresolved workspace).
public protocol FileRelocator: AnyObject {
    @MainActor
    func relocate(file: CEWorkspaceFile, to destination: URL) throws -> CEWorkspaceFile?
}

/// Default used when no app shell is present (tests, previews); performs no move.
public final class NoOpFileRelocator: FileRelocator {
    public init() {}
    public func relocate(file: CEWorkspaceFile, to destination: URL) throws -> CEWorkspaceFile? { nil }
}
