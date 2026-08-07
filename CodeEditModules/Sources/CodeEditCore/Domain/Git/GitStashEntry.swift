//
//  GitStashEntry.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/20/23.
//

import Foundation

public struct GitStashEntry: Hashable, Sendable {
    public let index: Int
    public let message: String
    public let date: Date

    public init(
        index: Int,
        message: String,
        date: Date
    ) {
        self.index = index
        self.message = message
        self.date = date
    }
}
