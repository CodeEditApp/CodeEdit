//
//  URL+FuzzySearchable.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 03.02.24.
//

import Foundation

extension URL: FuzzySearchable {
    var searchableString: String {
        return self.lastPathComponent
    }
}
