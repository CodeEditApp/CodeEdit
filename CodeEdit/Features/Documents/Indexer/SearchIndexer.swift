//
//  SearchIndexer.swift
//  CodeEdit
//
//  Created by Tom Ludwig on 18.11.23.
//

import Foundation

/// Indexer using SKIndex
public class SearchIndexer {
    let modifyIndexQueue = DispatchQueue(label: "app.codeedit.CodeEdit.ModifySearchIndex")

    var index: SKIndex?

    init(index: SKIndex) {
        self.index = index
    }

    deinit {
        self.close()
    }

    /// Flush any pending commands to the search index. Flush should always be called before performing a search
    public func flush() {
        if let index = self.index {
            SKIndexFlush(index)
        }
    }

    /// Reduce the size of index where possible
    ///
    /// - Warning: Do NOT call on the main thread
    public func compact() {
        if let index = self.index {
            SKIndexCompact(index)
        }
    }

    /// Remove any documents that have no search terms
    public func cleanUp() -> Int {
        let allDocs = self.fullDocuments(termState: .empty)
        var removedCount = 0
        for docID in allDocs {
            _ = self.remove(document: docID.document)
            removedCount += 1
        }
        return removedCount
    }

    /// Close the index
    public func close() {
        if let index = self.index {
            SKIndexClose(index)
            self.index = nil
        }
    }

    /// Call  once at application launch to tell Search Kit to use the Spotlight metadata importers.
    lazy var dataExtractorLoaded: Bool = {
        SKLoadDefaultExtractorPlugIns()
        return true
    }()

    /// Stop words for the index, 
    /// these are common words which should be ignored because they are not useful for searching
    private(set) lazy var stopWords: Set<String> = {
        var stopWords: Set<String> = []
        if let index = self.index,
           let properties = SKIndexGetAnalysisProperties(self.index).takeRetainedValue() as? [String: Any],
           let newStopWords = properties[kSKStopWords as String] as? Set<String> {
            stopWords = newStopWords
        }
        return stopWords
    }()

    public enum IndexType: UInt32 {
        /// Unknown index type (kSKIndexUnknown)
        case unknown = 0
        /// Inverted index, mapping terms to documents (kSKIndexInverted)
        case inverted = 1
        /// Vector index, mapping documents to terms (kSKIndexVector)
        case vector = 2
        /// Index type with all the capabilities of an inverted and a vector index (kSKIndexInvertedVector)
        case invertedVector = 3
    }

    /// A class for creating properties used in the creation of a Search Kit index.
    /// **Available Options:**
    /// - `indexType`: The type of the index to be created.
    ///     Options include `.unknown`, `.inverted`, `.vector` or `.invertedVector`
    /// - `proximityIndexing`: A Boolean flag indicating whether or not Search Kit should use proximity indexing.
    /// - `stopWords`: A set of stop-words — words not to index.
    /// - `minTermLength`: The minimum term length to index (defaults to 1).
    public class CreateProperties {
        /// The type of the index to be created
        private(set) var indexType: SKIndexType = kSKIndexInverted
        /// Whether the index should use proximity indexing
        private(set) var proximityIndexing: Bool = false
        /// The stop words for the index
        private(set) var stopWords: Set<String> = Set<String>()
        /// The minimum size of word to add to the index
        private(set) var minTermLength: UInt = 1

        /// Create a properties object with the specified creation parameters
        ///
        /// - Parameters:
        ///   - indexType: The type of index
        ///   - proximityIndexing: A Boolean flag indicating whether or not Search Kit should use proximity indexing
        ///   - stopWords: A set of stop-words — words not to index
        ///   - minTermLength: The minimum term length to index (defaults to 1)
        public init(
            indexType: SearchIndexer.IndexType = .inverted,
            proximityIndexing: Bool = false,
            stopWords: Set<String> = [],
            minTermLength: UInt = 1
        ) {
            self.indexType = SKIndexType(indexType.rawValue)
            self.proximityIndexing = proximityIndexing
            self.stopWords = stopWords
            self.minTermLength = minTermLength
        }

        /// Returns a CFDictionary object to use for the call to SKIndexCreate
        func properties() -> CFDictionary {
            let properties: [CFString: Any] = [
                kSKProximityIndexing: self.proximityIndexing,
                kSKStopWords: self.stopWords,
                kSKMinTermLength: self.minTermLength,
            ]
            return properties as CFDictionary
        }
    }

}
