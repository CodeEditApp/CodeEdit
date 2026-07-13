//
//  URL+AbsolutePath.swift
//  CETerminal
//
//  Created by Matthijs Eikelenboom on 13/07/2026.
//

import Foundation

extension URL {
    /// The non-percent-encoded absolute path.
    var absolutePath: String {
        absoluteURL.path(percentEncoded: false)
    }
}
