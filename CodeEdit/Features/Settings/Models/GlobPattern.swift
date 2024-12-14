//
//  GlobPattern.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/2/24.
//

import Foundation

/// A simple model that associates a UUID with a glob pattern string.
///
/// This type does not interpret or validate the glob pattern itself.
/// It is simply an identifier (`id`) and the glob pattern string (`value`) associated with it.
struct GlobPattern: Identifiable, Hashable, Decodable, Encodable {
    /// Ephemeral UUID used to uniquely identify this instance in the UI
    var id = UUID()

    /// The Glob Pattern string
    var value: String
}
