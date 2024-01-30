//
//  SearchIndexer+AsyncController.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 18.11.23.
//

import Foundation

extension SearchIndexer {
    /// Manager for SearchIndexer object that supports async calls to the index
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

        /// Performs an asynchronous progressive search on the index for the specified query.
        ///
        /// - Parameters:
        ///   - query: The search query string.
        ///   - maxResults: The maximum number of results to retrieve in each chunk.
        ///   - timeout: The timeout duration for each search operation. Default is 1.0 second.
        ///
        /// - Returns: An asynchronous stream (`AsyncStream`) of search results in chunks.
        /// The search results are returned in the form of a `SearchIndexer.ProgressiveSearch.Results` object.
        ///
        /// This function initiates a progressive search on the index for the specified query
        /// and asynchronously yields search results in chunks using an `AsyncStream`.
        /// The search continues until there are no more results or the specified timeout is reached.
        ///
        /// - Warning: Prior to calling this function,
        /// ensure that the `index` has been flushed to search within the most up-to-date data.
        ///
        /// Example usage:
        /// ```swift
        /// let searchStream = await asyncController.search(query: searchQuery, 20)
        /// for try await result in searchStream {
        ///     // Process each result
        ///     print(result)
        /// }
        /// ```
        func search(
            query: String,
            _ maxResults: Int,
            timeout: TimeInterval = 1.0
        ) async -> AsyncStream<SearchIndexer.ProgressiveSearch.Results> {
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

        /// Adds files from an array of TextFile objects to the index asynchronously.
        ///
        /// - Parameters:
        ///   - files: An array of TextFile objects containing the information about the files to be added.
        ///   - flushWhenComplete: A boolean flag indicating whether to flush 
        ///   the index when the operation is complete. Default is `false`.
        ///
        /// - Returns: An array of booleans indicating the success of adding each file to the index.
        func addText(
            files: [TextFile],
            flushWhenComplete: Bool = false
        ) async -> [Bool] {

            var addedFiles = [Bool]()

            // Asynchronously iterate through the provided files using a task group
            await withTaskGroup(of: Bool.self) { taskGroup in
                for file in files {
                    taskGroup.addTask {
                        // Add the file to the index and return the success status
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

        /// Adds files from an array of URLs to the index asynchronously.
        ///
        /// - Parameters:
        ///   - urls: An array of URLs representing the file locations to be added to the index.
        ///   - flushWhenComplete: A boolean flag indicating whether to flush
        ///   the index when the operation is complete. Default is `false`.
        ///
        /// - Returns: An array of booleans indicating the success of adding each file to the index.
        /// - Warning: Prefer using `addText` when possible as SearchKit does not have the ability
        ///  to read every file type. For example, it is often not possible to read Swift files.
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

        /// Adds files from a folder specified by the given URL to the index asynchronously.
        ///
        /// - Parameters:
        ///   - url: The URL of the folder containing files to be added to the index.
        ///   - flushWhenComplete: A boolean flag indicating whether to flush 
        ///   the index when the operation is complete. Default is `false`.
        ///
        /// This function uses asynchronous processing to add files from the specified folder to the index.
        ///
        /// - Note: Subfolders within the specified folder are also processed.
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
