//
//  SearchState.swift
//  CodeEdit
//
//  Created by Tom Ludwig on 16.01.24.
//

import Foundation
import CodeEditCore
import Combine
import Factory

/// Manages the search/find state for a workspace, including indexing, search results,
/// and find-and-replace operations. Extracted from Workspace to be independently
/// injectable and testable.
public final class SearchState: ObservableObject {
    public enum IndexStatus: Equatable, Sendable {
        case none
        case indexing(progress: Double)
        case done
    }

    public enum FindNavigatorStatus: Equatable, Sendable {
        case none
        case searching
        case replacing
        case found
        case replaced(updatedFiles: Int)
        case failed(errorMessage: String)
    }

    @Published public var searchResult: [SearchResultModel] = []
    @Published public var searchResultsFileCount: Int = 0
    @Published public var searchResultsCount: Int = 0
    /// Stores the user's input, shown when no files are found, and persists across navigation items.
    @Published public var searchQuery: String = ""
    @Published public var replaceText: String = ""

    /// The find/replace primitive shared with the Editor feature, kept in sync with
    /// `searchQuery`/`replaceText` below. See `Packages/Foundation/CodeEditCore`.
    public let query = FindReplaceQuery()

    private var queryBridgeCancellables: Set<AnyCancellable> = []

    @Published public var indexStatus: IndexStatus = .none

    @Published public var findNavigatorStatus: FindNavigatorStatus = .none

    @Published public var shouldFocusSearchField: Bool = false

    public let workspaceURL: URL

    @LazyInjected(\.eventBus)
    var eventBus

    var tempSearchResults = [SearchResultModel]()
    public var caseSensitive: Bool = false
    public var indexer: SearchIndexer?
    public var selectedMode: [SearchModeModel] = [
        .Find,
        .Text,
        .Containing
    ]

    public init(workspaceURL: URL) {
        self.workspaceURL = workspaceURL
        self.indexer = SearchIndexer.Memory.create()
        addProjectToIndex()
        bridgeFindReplaceQuery()
    }

    /// Keeps `searchQuery`/`replaceText` and `query` in sync in both directions, so Editor can
    /// depend on `query` (a `CodeEditCore` type) without importing this feature.
    private func bridgeFindReplaceQuery() {
        query.$searchQuery
            .receive(on: RunLoop.main)
            .sink { [weak self] newQuery in
                if self?.searchQuery != newQuery {
                    self?.searchQuery = newQuery
                }
            }
            .store(in: &queryBridgeCancellables)
        $searchQuery
            .receive(on: RunLoop.main)
            .sink { [weak self] newQuery in
                if self?.query.searchQuery != newQuery {
                    self?.query.searchQuery = newQuery
                }
            }
            .store(in: &queryBridgeCancellables)

        query.$replaceText
            .receive(on: RunLoop.main)
            .sink { [weak self] newText in
                if self?.replaceText != newText {
                    self?.replaceText = newText
                }
            }
            .store(in: &queryBridgeCancellables)
        $replaceText
            .receive(on: RunLoop.main)
            .sink { [weak self] newText in
                if self?.query.replaceText != newText {
                    self?.query.replaceText = newText
                }
            }
            .store(in: &queryBridgeCancellables)
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
