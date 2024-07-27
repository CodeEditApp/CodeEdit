//
//  Collection+subscript_safe.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/07/05.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
