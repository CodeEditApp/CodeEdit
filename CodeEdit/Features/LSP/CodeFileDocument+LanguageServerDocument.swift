//
//  CodeFileDocument+LanguageServerDocument.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import AppKit
import CodeEditDocument

extension CodeFileDocument: LanguageServerDocument {
    /// A stable string to use when identifying documents with language servers.
    /// Needs to be a valid URI, so always returns with the `file://` prefix to indicate it's a file URI.
    var languageServerURI: String? {
        fileURL?.lspURI
    }
}
