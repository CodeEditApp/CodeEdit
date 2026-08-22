//
//  Theme+FuzzyMatchable.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 14.08.24.
//

import Foundation
import CodeEditSettings
import CodeEditCore

extension Theme: FuzzyMatchable {
    public var searchableString: String {
        return id
    }
}
