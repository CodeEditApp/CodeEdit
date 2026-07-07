//
//  URL+AbsolutePath.swift
//  CodeEditDocument
//
//  Created by Matthijs Eikelenboom.
//

import Foundation

extension URL {
    /// The non-percent-encoded absolute path. Package-internal copy of the app's helper
    /// (kept private to this module to avoid a cross-module import ripple).
    var absolutePath: String {
        absoluteURL.path(percentEncoded: false)
    }
}
