//
//  Commit.swift
//  
//
//  Created by Marco Carnevali on 27/03/22.
//

import Foundation.NSDate

/// Model class to help map commit history log data
public struct Commit: Equatable, Hashable, Identifiable {
    public var id = UUID()
    public let hash: String
    public let commitHash: String
    public let message: String
    public let author: String
    public let authorEmail: String
    public let commiter: String
    public let commiterEmail: String
    public let date: Date
}
