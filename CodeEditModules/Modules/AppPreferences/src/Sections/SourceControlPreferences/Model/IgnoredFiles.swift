//
//  IgnoredFiles.swift
//  
//
//  Created by Nanashi Li on 2022/04/08.
//

import Foundation

public struct IgnoredFiles: Codable, Hashable, Identifiable {
    public var id: Int
    public var name: String

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

}
