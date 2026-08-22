//
//  SearchState+FindAndReplace.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 02.01.24.
//

import Foundation

extension SearchState {
    /// Performs a search and replace operation in a collection of files based on the provided query.
    ///
    /// - Parameters:
    ///   - query: The search query to look for in the files.
    ///   - replacingTerm: The term to replace the matched query with.
    ///
    /// - Important: This function relies on an indexer and assumes that it has been previously set.
    /// If the indexer is not available, the function will return early.
    /// Also make sure to flush any pending changes to the index before calling this function.
    public func findAndReplace(query: String, replacingTerm: String) async throws {
        await setStatus(.replacing)
        let searchQuery = getSearchTerm(query)
        guard let indexer = indexer else { return }

        var errorCount: Int = 0, updatedFilesCount: Int = 0
        let asyncController = SearchIndexer.AsyncManager(index: indexer)

        let searchStream = await asyncController.search(query: searchQuery, 20)

        for try await result in searchStream {
            await withTaskGroup(of: Bool.self) { taskGroup in
                for file in result.results {
                    taskGroup.addTask {
                        do {
                            try await self.replaceOccurrencesInFile(
                                fileURL: file.url,
                                query: query,
                                replacingTerm: replacingTerm
                            )
                            return true
                        } catch {
                            // TODO: Write log; issue number: #0000
                            return false
                        }
                    }
                }

                for await taskGroupResults in taskGroup {
                    if taskGroupResults {
                        updatedFilesCount += 1
                    } else {
                        errorCount += 1
                    }
                }
            }
        }

        // Display the replacing results to the user
        if updatedFilesCount == 0 && errorCount == 0 {
            // No results where found
            await setStatus(.failed(errorMessage: "No files in the workspace matched: \(query)"))
        } else if updatedFilesCount == 0 && errorCount > 0 {
            // All files failed to updated
            await setStatus(
                .failed(
                    errorMessage: "All files failed to update. (\(errorCount)) " +
                    "errors occurred. Check logs for more information"
                )
            )
        } else if updatedFilesCount > 0 && errorCount > 0 {
            // Some files updated successfully, some failed
            await setStatus(
                .failed(
                    errorMessage: "\(updatedFilesCount) successfully updated, " +
                    "\(errorCount) errors occurred. Please check logs for more information."
                )
            )
        } else {
            // Each files updated successfully
            await setStatus(.replaced(updatedFiles: updatedFilesCount))
        }
    }

    /// Replaces occurrences of a specified query with a given replacement term in the content of a file.
    ///
    /// - Parameters:
    ///     - fileURL: The URL of the file to be processed.
    ///     - query:  The string to be searched for and replaced.
    ///     - replacingTerm: The string to replace occurrences of the query.
    ///     - options: The options for the search and replace operation.
    ///             You can use options such as regular expression or case-insensitivity.
    ///
    /// The function performs the replacement in memory and then writes the modified content back to the file
    func replaceOccurrencesInFile(
        fileURL: URL,
        query: String,
        replacingTerm: String
    ) async throws {
        let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
        let updatedContent = fileContent.replacingOccurrences(
            of: query,
            with: replacingTerm,
            options: self.replaceOptions
        )

        try updatedContent.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    func setStatus(_ status: FindNavigatorStatus) async {
        await MainActor.run {
            self.findNavigatorStatus = status
        }
    }
}
