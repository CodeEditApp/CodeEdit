//
//  AsyncFileIterator.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/4/23.
//

import Foundation

/// Given a list of file URLs, asynchronously fetches their contents and returns them iteratively.
/// Returns files as a ``SearchIndexer/AsyncManager/TextFile`` struct, used to index workspaces.
public struct AsyncFileIterator: AsyncSequence, AsyncIteratorProtocol {
    public typealias TextFile = SearchIndexer.AsyncManager.TextFile
    public typealias Element = (TextFile, Int)

    let fileURLs: [URL]
    var currentIdx = 0

    public init(fileURLs: [URL]) {
        self.fileURLs = fileURLs
    }

    public mutating func next() async -> Element? {
        guard !Task.isCancelled else {
            return nil
        }

        defer {
            currentIdx += 1
        }

        // Loop until we either find a loadable file or run out of URLs
        var foundContent: TextFile?
        while foundContent == nil {
            guard currentIdx < fileURLs.count else {
                return nil
            }

            let fileURL = fileURLs[currentIdx]
            if let content = try? String(contentsOf: fileURL) {
                foundContent = TextFile(url: fileURL.standardizedFileURL, text: content)
            } else {
                currentIdx += 1
            }
        }
        return (foundContent!, currentIdx)
    }

    public func makeAsyncIterator() -> AsyncFileIterator {
        self
    }
}
