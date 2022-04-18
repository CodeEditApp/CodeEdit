//
//  Commit.swift
//  
//
//  Created by Marco Carnevali on 27/03/22.
//

import Foundation.NSDate

public struct Commit: Equatable, Hashable {
    public let hash: String
    public let message: String
    public let author: String
    public let date: Date
}
