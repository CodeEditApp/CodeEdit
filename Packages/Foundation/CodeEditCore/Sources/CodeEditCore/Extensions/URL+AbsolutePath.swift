//
//  URL+AbsolutePath.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 14/07/2026.
//

import Foundation

public extension URL {
    /// The non-percent-encoded absolute path.
    var absolutePath: String {
        absoluteURL.path(percentEncoded: false)
    }
}
