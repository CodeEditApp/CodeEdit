//
//  URL+Filename.swift
//  CodeEdit
//
//  Created by Axel Martinez on 5/8/24.
//

import Foundation

extension URL {
    var fileName: String {
        self.lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
