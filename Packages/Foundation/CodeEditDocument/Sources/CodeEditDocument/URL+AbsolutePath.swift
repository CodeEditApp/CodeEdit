//
//  URL+AbsolutePath.swift
//  CodeEditDocument
//
//  Created by Matthijs Eikelenboom.
//

import Foundation

extension URL {
    /// The non-percent-encoded absolute path.
    public var absolutePath: String {
        absoluteURL.path(percentEncoded: false)
    }
}
