//
//  URL+ResourceValues.swift
//  CodeEditCore
//
//  Created by Axel Martinez on 27/6/24.
//

import Foundation
import UniformTypeIdentifiers

public extension URL {
    fileprivate var resourceValues: URLResourceValues? {
        try? self.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey, .contentTypeKey])
    }

    /// Whether this URL points to a directory.
    var isFolder: Bool {
        resourceValues?.isDirectory ?? false
    }

    /// Whether this URL points to a symbolic link or a Finder alias.
    var isSymbolicLink: Bool {
        resourceValues?.isSymbolicLink ?? false || (resourceValues?.contentType ?? .item) == .aliasFile
    }

    /// The uniform type of the item at this URL, or `nil` if the resource value cannot be read.
    var contentType: UTType? {
        resourceValues?.contentType
    }
}
