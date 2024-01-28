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

    @Published var openQuicklyFiles: [URL] = []

    @Published var isShowingOpenQuicklyFiles: Bool = false

    let fileURL: URL

    var runningTask: Task<Void, Never>?

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func fetchOpenQuickly() {
        let startdate = Date()
        guard openQuicklyQuery != "" else {
            openQuicklyFiles = []
            self.isShowingOpenQuicklyFiles = !openQuicklyFiles.isEmpty
            return
        }

        runningTask?.cancel()
        runningTask = Task.detached(priority: .userInitiated) {
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
                guard !Task.isCancelled else { return }
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
//                let orderedFiles = await FuzzySearch.search(query: self.openQuicklyQuery, in: filteredFiles)
                let files = filteredFiles.fuzzySearch(query: self.openQuicklyQuery.trimmingCharacters(in: .whitespaces)).map {
                    $0.item
                }

                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.openQuicklyFiles = files
                    self.isShowingOpenQuicklyFiles = !self.openQuicklyFiles.isEmpty
                    print(Date().timeIntervalSince(startdate))
                }
            }
        }
    }
}

extension URL: FuzzySearchable {
    var searchableString: String {
        return String(self.lastPathComponent.split(separator: ".")[0])
    }
}
