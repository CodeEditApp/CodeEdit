//
//  URL+FileName.swift
//  CodeEditCore
//
//  Created by Axel Martinez on 5/8/24.
//

import Foundation

extension URL {
    /// The last path component with surrounding whitespace and newlines trimmed.
    public var fileName: String {
        self.lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
