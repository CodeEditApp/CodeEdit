//
//  WorkspaceDocument+SearchState.swift
//  CodeEdit
//
//  Created by Tom Ludwig on 16.01.24.
//

import Foundation

extension WorkspaceDocument {
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

        unowned var workspace: WorkspaceDocument
        var tempSearchResults = [SearchResultModel]()
        var caseSensitive: Bool = false
        var indexer: SearchIndexer?
        var selectedMode: [SearchModeModel] = [
            .Find,
            .Text,
            .Containing
        ]

        init(_ workspace: WorkspaceDocument) {
            self.workspace = workspace
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
}
