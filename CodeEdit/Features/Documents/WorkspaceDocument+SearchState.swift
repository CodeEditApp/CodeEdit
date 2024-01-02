//
//  WorkspaceDocument+Search.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 30.04.22.
//

import Foundation

extension WorkspaceDocument {
    final class SearchState: ObservableObject {
        enum IndexStatus {
            case none
            case indexing(progress: Double)
            case done
        }

        @Published var searchResult: [SearchResultModel] = []
        @Published var searchResultsFileCount: Int = 0
        @Published var searchResultsCount: Int = 0

        @Published var indexStatus: IndexStatus = .none

        unowned var workspace: WorkspaceDocument
        var tempSearchResults = [SearchResultModel]()
        var ignoreCase: Bool = true
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

            if ignoreCase {
                options.insert(.caseInsensitive)
            }

            return options
        }()
    }
}
