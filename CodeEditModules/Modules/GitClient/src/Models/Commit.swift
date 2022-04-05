//
//  Commit.swift
//  
//
//  Created by Marco Carnevali on 27/03/22.
//

import Foundation.NSDate
public extension GitClient {
    struct Commit: Equatable {
        let hash: String
        let message: String
        let author: String
        let date: Date
    }
}
