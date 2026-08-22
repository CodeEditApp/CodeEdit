//
//  CodeFileDocument+LanguageServerDocument.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import AppKit
import CodeEditDocument

extension CodeFileDocument: @preconcurrency LanguageServerDocument {
    /// A stable string to use when identifying documents with language servers.
    /// Needs to be a valid URI, so always returns with the `file://` prefix to indicate it's a file URI.
    public var languageServerURI: String? {
        fileURL?.lspURI
    }
}
