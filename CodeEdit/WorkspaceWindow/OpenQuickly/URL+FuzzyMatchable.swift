//
//  URL+FuzzyMatchable.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 03.02.24.
//

import Foundation
import CodeEditCore

extension URL: FuzzyMatchable {
    public var searchableString: String {
        return self.lastPathComponent
    }
}
