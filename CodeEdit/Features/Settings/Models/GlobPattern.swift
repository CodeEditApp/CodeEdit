//
//  GlobPattern.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/2/24.
//

import Foundation

struct GlobPattern: Identifiable, Hashable, Decodable, Encodable {
    /// Ephimeral UUID used to track its representation in the UI
    var id = UUID()

    /// The Glob Pattern to render
    var value: String
}
