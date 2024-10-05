//
//  Theme+FuzzySearchable.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 14.08.24.
//

import Foundation

extension Theme: FuzzySearchable {
    var searchableString: String {
        return id
    }
}
