//
//  Array+subscript_safe.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/7/3.
//

import Foundation

extension Array {
    /// Returns nil if the index is out of bounds.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
