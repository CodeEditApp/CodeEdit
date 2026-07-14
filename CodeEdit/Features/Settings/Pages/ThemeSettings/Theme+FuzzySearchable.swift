//
//  Theme+FuzzySearchable.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 14.08.24.
//

import Foundation
import CodeEditSettings
import CodeEditCore

extension Theme: FuzzySearchable {
    public var searchableString: String {
        return id
    }
}
