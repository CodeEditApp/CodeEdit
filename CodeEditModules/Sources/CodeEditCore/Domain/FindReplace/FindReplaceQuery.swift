//
//  FindReplaceQuery.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom.
//

import Foundation

/// Shared find/replace query text, editable by both the Search and Editor features without
/// either depending on the other. Owned by Search's `SearchState` (workspace-scoped); Editor
/// mirrors it into each open file's find panel.
public final class FindReplaceQuery: ObservableObject {
    @Published public var searchQuery: String = ""
    @Published public var replaceText: String = ""

    public init() {}
}
