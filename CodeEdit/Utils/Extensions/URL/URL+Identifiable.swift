//
//  URL+Identifiable.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/5/25.
//

import Foundation

extension URL: Identifiable {
    public var id: String {
        absoluteString
    }
}
