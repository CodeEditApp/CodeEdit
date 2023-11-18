//
//  SearchIndexer+AsyncController.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 18.11.23.
//

import Foundation

extension SearchIndexer {
    /// Manager for SearchIndexer objct that supports async calls to the index
    class AsyncManager {
        /// An instance of the SearchIndexer
        let index: SearchIndexer
        private let addQueue = DispatchQueue(label: "com.SearchkitDemo.addQueue", attributes: .concurrent)
        private let searchQueue = DispatchQueue(label: "com.SearchkitDemo.searchQueue", attributes: .concurrent)

        init(index: SearchIndexer) {
            self.index = index
        }

        class TextFile {
            let url: URL
            let text: String

            /// Create a text async task
            ///
            /// - Parameters:
            ///   - url: the identifying document URL
            ///   - text: The text to add to the index
            init(url: URL, text: String) {
                self.url = url
                self.text = text
            }
        }

        // MARK: - Search

        // TODO: utilise concurrency instead of completion handler
        func search(
            query: String,
            _ maxResults: Int,
            timeout: TimeInterval = 1.0,
            complete: @escaping (SearchIndexer.ProgressivSearch.Results) -> Void
        ) {
            let search = index.progressiveSearch(query: query)
            searchQueue.async {
                let results = search.getNextSearchResultsChunk(limit: maxResults, timeout: timeout)
                let searchResults = SearchIndexer.ProgressivSearch.Results(
                    moreResultsAvailable: results.moreResultsAvailable,
                    results: results.results
                )

                DispatchQueue.main.async {
                    complete(searchResults)
                }
            }
        }

        // MARK: - Add

        func addText(
            files: [TextFile],
            flushWhenComplete: Bool = false
            //            complete: @escaping ([Bool]) -> Void
        ) async -> [Bool] {

            var addedFiles = [Bool]()

            await withTaskGroup(of: Bool.self) { taskGroup in
                for file in files {
                    taskGroup.addTask {
                        return self.index.addFileWithText(file.url, text: file.text, canReplace: false)
                    }
                }

                for await result in taskGroup {
                    addedFiles.append(result)
                }
            }
            if flushWhenComplete {
                index.flush()
            }
            return addedFiles
        }

        func addFiles(
            urls: [URL],
            flushWhenComplete: Bool = false
        ) async -> [Bool] {
            var addedURLs = [Bool]()

            await withTaskGroup(of: Bool.self) { taskGroup in
                for url in urls {
                    taskGroup.addTask {
                        return self.index.addFile(fileURL: url, canReplace: false)
                    }
                }

                for await results in taskGroup {
                    addedURLs.append(results)
                }
            }

            return addedURLs
        }

        func addFolder(
            url: URL,
            flushWhenComplete: Bool = false
        ) {
            let dispatchGroup = DispatchGroup()

            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles],
                errorHandler: nil
            )!

            for case let fileURL as URL in enumerator {
                dispatchGroup.enter()

                if FileHelper.urlIsFolder(url) {
                    addQueue.async { [weak self] in
                        guard let self = self else { return }
                        self.addFolder(url: url)
                        dispatchGroup.leave()
                    }
                } else {
                    addQueue.async { [weak self] in
                        guard let self = self else { return }
                        _ = self.index.addFile(fileURL: fileURL, canReplace: false)
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                if flushWhenComplete {
                    self.index.flush()
                }
            }
        }
    }
}
