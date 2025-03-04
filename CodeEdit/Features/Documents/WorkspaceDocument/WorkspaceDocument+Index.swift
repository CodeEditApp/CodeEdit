//
//  WorkspaceDocument+Index.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 02.01.24.
//

import Foundation

extension WorkspaceDocument.SearchState {
    /// Adds the contents of the current workspace URL to the search index.
    /// That means that the contents of the workspace will be indexed and searchable.
    func addProjectToIndex() async {
        guard let indexer = indexer else { return }
        guard let url = workspace.fileURL else { return }

        indexStatus = .indexing(progress: 0.0)

        // Create activity using new API
        let activity = await MainActor.run {
            workspace.activityManager.post(
                title: "Indexing | Processing files",
                message: "Creating an index to enable fast and accurate searches within your codebase.",
                isLoading: true
            )
        }
        
        let (progressStream, continuation) = AsyncStream<Double>.makeStream()
        // Dispatch this now, we want to continue after starting to monitor
        Task { await self.monitorProgressStream(progressStream, activityId: activity.id) }

        Task.detached {
            let filePaths = self.getFileURLs(at: url)
            let asyncController = SearchIndexer.AsyncManager(index: indexer)
            var lastProgress: Double = 0

            // Batch our progress updates
            var pendingProgress: Double?

            for await (file, index) in AsyncFileIterator(fileURLs: filePaths) {
                _ = await asyncController.addText(files: [file], flushWhenComplete: false)
                let progress = Double(index) / Double(filePaths.count)

                // Send only if difference is > 1%
                if progress - lastProgress > 0.01 {
                    lastProgress = progress
                    pendingProgress = progress

                    // Only update UI every 100ms
                    if index == filePaths.count - 1 || pendingProgress != nil {
                        continuation.yield(progress)
                        pendingProgress = nil
                    }
                }
            }

            asyncController.index.flush()

            await MainActor.run {
                self.indexStatus = .done
                self.workspace.activityManager.update(
                    id: activity.id,
                    title: "Finished indexing",
                    isLoading: false
                )
                self.workspace.activityManager.delete(
                    id: activity.id,
                    delay: 4.0
                )
            }
        }
    }

    /// Monitors a progress stream from ``addProjectToIndex()`` and updates ``indexStatus`` and the workspace's activity
    /// manager accordingly.
    ///
    /// Without this, updates can come too fast for `Combine` to handle and can cause crashes.
    ///
    /// - Parameters:
    ///   - stream: The stream to monitor for progress updates, in %.
    ///   - activityId: The activity ID that's being monitored
    @MainActor
    private func monitorProgressStream(_ stream: AsyncStream<Double>, activityId: String) async {
        for await progressUpdate in stream.debounce(for: .milliseconds(10)) {
            self.indexStatus = .indexing(progress: progressUpdate)
            self.workspace.activityManager.update(
                id: activityId,
                percentage: progressUpdate
            )
        }
    }

    /// Retrieves an array of file URLs within the specified directory URL.
    ///
    /// - Parameter url: The URL of the directory to search for files.
    ///
    /// - Returns: An array of file URLs found within the specified directory.
    func getFileURLs(at url: URL) -> [URL] {
        let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        )
        return enumerator?.allObjects as? [URL] ?? []
    }

    /// Retrieves the contents of a files  from the specified file paths.
    ///
    /// - Parameter filePaths: An array of file URLs representing the paths of the files.
    ///
    /// - Returns: An array of `TextFile` objects containing the standardised file URLs and text content.
    func getFileContent(from filePaths: [URL]) async -> [SearchIndexer.AsyncManager.TextFile] {
        var textFiles = [SearchIndexer.AsyncManager.TextFile]()
        for file in filePaths {
            if let content = try? String(contentsOf: file) {
                textFiles.append(
                    SearchIndexer.AsyncManager.TextFile(url: file.standardizedFileURL, text: content)
                )
            }
        }
        return textFiles
    }
}
