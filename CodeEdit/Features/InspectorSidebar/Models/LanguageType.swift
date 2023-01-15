//
//  LanguageType.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/04/17.
//

import Foundation

/// A temporary struct for the inspector. This should not be used to identify languages for syntax highlighting
struct LanguageType: Identifiable, Hashable {
    /// The name of the language type
    let name: String
    /// The unique ID of the language type, this usually corresponds to the correct file extension,
    /// but should not be relied on when creating files.
    let id: String
}
