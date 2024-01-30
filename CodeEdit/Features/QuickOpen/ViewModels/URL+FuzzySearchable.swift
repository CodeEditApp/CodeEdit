//
//  URL+FuzzySearchable.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 30.01.24.
//

import Foundation

extension URL: FuzzySearchable {
    var searchableString: String {
        return self.lastPathComponent
    }
}
