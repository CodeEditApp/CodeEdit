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
    func addProjectToIndex() {
        startProjectIndexing()
    }

    /// Starts project indexing without blocking the caller.
    func startProjectIndexing() {
        guard let indexer = indexer else { return }
        guard let url = workspace.fileURL else { return }

        let previousTask = indexingTask
        previousTask?.cancel()
        indexingTask = Task { [weak self] in
            await previousTask?.value
            guard !Task.isCancelled else { return }

            await self?.indexProject(indexer: indexer, url: url)
        }
    }

    /// Indexes the project and returns after the index has been flushed.
    func indexProject() async {
        let previousTask = indexingTask
        previousTask?.cancel()
        await previousTask?.value
        indexingTask = nil

        guard let indexer = indexer else { return }
        guard let url = workspace.fileURL else { return }

        await indexProject(indexer: indexer, url: url)
    }

    private func indexProject(indexer: SearchIndexer, url: URL) async {
        let uuidString = UUID().uuidString
        await publishIndexingStarted(id: uuidString)

        let filePaths = getFileURLs(at: url)
        let asyncController = SearchIndexer.AsyncManager(index: indexer)
        var lastProgress: Double = 0

        for await (file, index) in AsyncFileIterator(fileURLs: filePaths) {
            guard !Task.isCancelled else {
                await publishIndexingCancelled(id: uuidString)
                return
            }

            _ = await asyncController.addText(files: [file], flushWhenComplete: false)
            let progress = Double(index + 1) / Double(filePaths.count)

            if progress - lastProgress > 0.005 || index == filePaths.count - 1 {
                lastProgress = progress
                await publishIndexingProgress(id: uuidString, progress: progress)
            }
        }

        guard !Task.isCancelled else {
            await publishIndexingCancelled(id: uuidString)
            return
        }

        asyncController.index.flush()
        await publishIndexingFinished(id: uuidString)
    }

    @MainActor
    private func publishIndexingStarted(id: String) {
        indexStatus = .indexing(progress: 0.0)
        let createInfo: [String: Any] = [
            "id": id,
            "action": "create",
            "title": "Indexing | Processing files",
            "message": "Creating an index to enable fast and accurate searches within your codebase.",
            "isLoading": true
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: createInfo)
    }

    @MainActor
    private func publishIndexingProgress(id: String, progress: Double) {
        indexStatus = .indexing(progress: progress)
        let updateInfo: [String: Any] = [
            "id": id,
            "action": "update",
            "percentage": progress
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: updateInfo)
    }

    @MainActor
    private func publishIndexingFinished(id: String) {
        indexStatus = .done
        let updateInfo: [String: Any] = [
            "id": id,
            "action": "update",
            "title": "Finished indexing",
            "isLoading": false
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: updateInfo)

        let deleteInfo: [String: Any] = [
            "id": id,
            "action": "deleteWithDelay",
            "delay": 4.0
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: deleteInfo)
    }

    @MainActor
    private func publishIndexingCancelled(id: String) {
        indexStatus = .done
        let deleteInfo: [String: Any] = [
            "id": id,
            "action": "delete"
        ]
        NotificationCenter.default.post(name: .taskNotification, object: nil, userInfo: deleteInfo)
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
