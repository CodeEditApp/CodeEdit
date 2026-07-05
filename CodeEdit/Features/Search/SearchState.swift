//
//  SearchState.swift
//  CodeEdit
//
//  Created by Tom Ludwig on 16.01.24.
//

import Foundation
import Search
import CodeEditCore
import Factory

/// Manages the search/find state for a workspace, including indexing, search results,
/// and find-and-replace operations. Extracted from Workspace to be independently
/// injectable and testable.
final class SearchState: ObservableObject {
    enum IndexStatus: Equatable {
        case none
        case indexing(progress: Double)
        case done
    }

    enum FindNavigatorStatus: Equatable {
        case none
        case searching
        case replacing
        case found
        case replaced(updatedFiles: Int)
        case failed(errorMessage: String)
    }

    @Published var searchResult: [SearchResultModel] = []
    @Published var searchResultsFileCount: Int = 0
    @Published var searchResultsCount: Int = 0
    /// Stores the user's input, shown when no files are found, and persists across navigation items.
    @Published var searchQuery: String = ""
    @Published var replaceText: String = ""

    @Published var indexStatus: IndexStatus = .none

    @Published var findNavigatorStatus: FindNavigatorStatus = .none

    @Published var shouldFocusSearchField: Bool = false

    let workspaceURL: URL

    @LazyInjected(\.eventBus)
    var eventBus

    var tempSearchResults = [SearchResultModel]()
    var caseSensitive: Bool = false
    var indexer: SearchIndexer?
    var selectedMode: [SearchModeModel] = [
        .Find,
        .Text,
        .Containing
    ]

    init(workspaceURL: URL) {
        self.workspaceURL = workspaceURL
        self.indexer = SearchIndexer.Memory.create()
        addProjectToIndex()
    }

    /// Represents the compare options to be used for find and replace.
    ///
    /// The `replaceOptions` property is a lazy, computed property that dynamically calculates
    /// the compare options based on the values of `selectedMode` and `ignoreCase`. It is used
    /// for controlling string replacement behavior for the find and replace functions.
    ///
    /// - Note: This property is implemented as a lazy property in the main class body because
    /// extensions cannot contain stored properties directly.
    lazy var replaceOptions: NSString.CompareOptions = {
        var options: NSString.CompareOptions = []

        if selectedMode.second == .RegularExpression {
            options.insert(.regularExpression)
        }

        if !caseSensitive {
            options.insert(.caseInsensitive)
        }

        return options
    }()
}
