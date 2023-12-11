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
        private let addQueue = DispatchQueue(label: "app.codeedit.CodeEdit.AddFilesToIndex", attributes: .concurrent)
        private let searchQueue = DispatchQueue(label: "app.codeedit.CodeEdit.SearchIndex", attributes: .concurrent)

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
        func search(
            query: String,
            _ maxResults: Int,
            timeout: TimeInterval = 1.0
        ) async -> AsyncStream<SearchIndexer.ProgressivSearch.Results> {
            let search = index.progressiveSearch(query: query)

            return AsyncStream { configuration in
                var moreResultsAvailable = true
                while moreResultsAvailable && !Task.isCancelled {
                    let results = search.getNextSearchResultsChunk(limit: maxResults, timeout: timeout)
                    moreResultsAvailable = results.moreResultsAvailable
                    configuration.yield(results)
                }
                configuration.finish()
            }
        }

        // MARK: - Add

        func addText(
            files: [TextFile],
            flushWhenComplete: Bool = false
        ) async -> [Bool] {

            var addedFiles = [Bool]()

            await withTaskGroup(of: Bool.self) { taskGroup in
                for file in files {
                    taskGroup.addTask {
                        return self.index.addFileWithText(file.url, text: file.text, canReplace: true)
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
                        return self.index.addFile(fileURL: url, canReplace: true)
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
                        _ = self.index.addFile(fileURL: fileURL, canReplace: true)
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
