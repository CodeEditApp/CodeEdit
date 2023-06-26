//
//  QuickOpenState.swift
//  CodeEditModules/QuickOpen
//
//  Created by Marco Carnevali on 05/04/22.
//

import Combine
import Foundation

final class QuickOpenViewModel: ObservableObject {

    typealias Item = any Resource

    @Published var openQuicklyQuery: String = ""

    @Published var openQuicklyFiles: [File] = []

    @Published var isShowingOpenQuicklyFiles: Bool = false

    weak var workspace: WorkspaceDocument?

    private let queue = DispatchQueue(label: "app.codeedit.CodeEdit.quickOpen.searchFiles")

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    func fetchOpenQuickly() async {
        guard openQuicklyQuery != "" else {
            openQuicklyFiles = []
            self.isShowingOpenQuicklyFiles = !openQuicklyFiles.isEmpty
            return
        }

        guard let workspace else { return }

        let urls = await workspace.fileMap.compactMap { $1 is File ? $0 : .none }

        /// sorts the filtered filePaths with the FuzzySearch
        let orderedURLs = FuzzySearch.search(query: self.openQuicklyQuery, in: urls)
        let orderedFiles = await Task { @MainActor in
            orderedURLs.compactMap { workspace.fileMap[$0] as? File }
        }.result

        if case .success(let success) = orderedFiles {
            self.openQuicklyFiles = success
            self.isShowingOpenQuicklyFiles = !self.openQuicklyFiles.isEmpty
        }
    }
}
