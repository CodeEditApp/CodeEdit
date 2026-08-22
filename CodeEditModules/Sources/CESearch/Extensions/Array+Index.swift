//
//  Array+Index.swift
//  CodeEdit
//
//  Created by Abe Malla on 7/24/25.
//

public extension Array {
    /// The second element of the array, or `nil` if the array has fewer than two elements.
    var second: Element? {
        self.count > 1 ? self[1] : nil
    }

    /// The third element of the array, or `nil` if the array has fewer than three elements.
    var third: Element? {
        self.count > 2 ? self[2] : nil
    }
}
