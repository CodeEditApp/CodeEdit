//
//  FileEditorOverrideValues.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom.
//

import Foundation

/// Per-file editor setting overrides, as plain values so `CodeEditCore` need not
/// name `CodeFileDocument` (which depends on Core) or `CodeLanguage` (heavy dep).
/// A `nil` field means "no override — use the global setting"; the language
/// override is carried as `CodeLanguage.id.rawValue`.
public struct FileEditorOverrideValues: Sendable, Equatable {
    public var indentOption: IndentOption?
    public var defaultTabWidth: Int?
    public var wrapLines: Bool?
    public var languageId: String?

    public init(
        indentOption: IndentOption? = nil,
        defaultTabWidth: Int? = nil,
        wrapLines: Bool? = nil,
        languageId: String? = nil
    ) {
        self.indentOption = indentOption
        self.defaultTabWidth = defaultTabWidth
        self.wrapLines = wrapLines
        self.languageId = languageId
    }
}
