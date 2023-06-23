//
//  QuickOpenState.swift
//  CodeEditModules/QuickOpen
//
//  Created by Marco Carnevali on 05/04/22.
//

import Combine
import Foundation

final class QuickOpenViewModel: ObservableObject {

    @Published var openQuicklyQuery: String = ""

    @Published var openQuicklyFiles: [CEWorkspaceFile] = []

    @Published var isShowingOpenQuicklyFiles: Bool = false

    let fileURL: URL

    private let queue = DispatchQueue(label: "app.codeedit.CodeEdit.quickOpen.searchFiles")

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func fetchOpenQuickly() {
        guard openQuicklyQuery != "" else {
            openQuicklyFiles = []
            self.isShowingOpenQuicklyFiles = !openQuicklyFiles.isEmpty
            return
        }

        queue.async { [weak self] in
            guard let self else { return }
            let enumerator = FileManager.default.enumerator(
                at: self.fileURL,
                includingPropertiesForKeys: [
                    .isRegularFileKey
                ],
                options: [
                    .skipsPackageDescendants
                ]
            )
            if let filePaths = enumerator?.allObjects as? [URL] {
                /// removes all filePaths which aren't regular files
                let filteredFiles = filePaths.filter { url in
                    do {
                        let values = try url.resourceValues(forKeys: [.isRegularFileKey])
                        return (values.isRegularFile ?? false)
                    } catch {
                        return false
                    }
                }

                /// sorts the filtered filePaths with the FuzzySearch
                let orderedFiles = FuzzySearch.search(query: self.openQuicklyQuery, in: filteredFiles)
                    .map { url in
                        CEWorkspaceFile(url: url, children: nil)
                    }

                DispatchQueue.main.async {
                    self.openQuicklyFiles = orderedFiles
                    self.isShowingOpenQuicklyFiles = !self.openQuicklyFiles.isEmpty
                }
            }
        }
    }
}
