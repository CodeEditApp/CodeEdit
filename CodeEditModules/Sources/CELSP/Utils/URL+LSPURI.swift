//
//  URL+LSPURI.swift
//  CodeEdit
//
//  Created by Khan Winter on 3/24/25.
//

import Foundation

extension URL {
    /// A stable string to use when identifying documents with language servers.
    /// Needs to be a valid URI, so always returns with the `file://` prefix to indicate it's a file URI.
    ///
    /// Use this whenever possible when using USLs in LSP processing if not using the ``LanguageServerDocument`` type.
    var lspURI: String {
        return "file://" + absolutePath
    }
}
