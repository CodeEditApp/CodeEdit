//
//  URL+ResouceValues.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/6/24.
//

import Foundation
import UniformTypeIdentifiers

extension URL {
    fileprivate var resourceValues: URLResourceValues? {
        try? self.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey, .contentTypeKey])
    }

    var isFolder: Bool {
        resourceValues?.isDirectory ?? false
    }

    var isSymbolicLink: Bool {
        resourceValues?.isSymbolicLink ?? false || (resourceValues?.contentType ?? .item) == .aliasFile
    }

    var contentType: UTType? {
        resourceValues?.contentType
    }
}
