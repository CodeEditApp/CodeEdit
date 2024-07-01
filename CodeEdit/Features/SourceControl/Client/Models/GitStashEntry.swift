//
//  GitStashEntry.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/20/23.
//

import Foundation

struct GitStashEntry: Hashable {
    let index: Int
    let message: String
    let date: Date
}
