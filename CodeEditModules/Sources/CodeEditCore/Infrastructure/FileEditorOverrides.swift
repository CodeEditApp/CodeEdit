//
//  FileEditorOverrides.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom.
//

import Foundation

/// Read/write seam for a file's editor setting overrides. Lets the File Inspector
/// edit per-file overrides without depending on the Editor feature's
/// `EditorManager` / `CodeFileDocument`. Workspace-scoped: one per window.
public protocol FileEditorOverrides: AnyObject {
    /// Current overrides for `file`; all fields `nil` when the file has no open document.
    @MainActor
    func overrides(for file: CEWorkspaceFile) -> FileEditorOverrideValues
    @MainActor
    func setIndentOption(_ value: IndentOption?, for file: CEWorkspaceFile)
    @MainActor
    func setDefaultTabWidth(_ value: Int?, for file: CEWorkspaceFile)
    @MainActor
    func setWrapLines(_ value: Bool?, for file: CEWorkspaceFile)
    @MainActor
    func setLanguageId(_ value: String?, for file: CEWorkspaceFile)
}

/// Default used when no editor is injected (tests, previews); no overrides, no-op writes.
public final class NoOpFileEditorOverrides: FileEditorOverrides {
    public init() {}
    public func overrides(for file: CEWorkspaceFile) -> FileEditorOverrideValues { .init() }
    public func setIndentOption(_ value: IndentOption?, for file: CEWorkspaceFile) {}
    public func setDefaultTabWidth(_ value: Int?, for file: CEWorkspaceFile) {}
    public func setWrapLines(_ value: Bool?, for file: CEWorkspaceFile) {}
    public func setLanguageId(_ value: String?, for file: CEWorkspaceFile) {}
}
