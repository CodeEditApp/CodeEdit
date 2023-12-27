//
//  SearchIndexer+File.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 18.11.23.
//

import Foundation

extension SearchIndexer {
    /// A file based index
    public class File: SearchIndexer {
        /// The file url where the index is located
        public let fileURL: URL

        private init(url: URL, index: SKIndex) {
            self.fileURL = url
            super.init(index: index)
        }

        /// Create a new file based index
        /// - Parameters:
        ///    - fileURL:The file URL to create the index at
        ///    - properties: The properties defining the capabilities of the index
        public convenience init?(fileURL: URL, properties: CreateProperties) {
            if !FileManager.default.fileExists(atPath: fileURL.absoluteString),
               let skIndex = SKIndexCreateWithURL(
                fileURL as CFURL,
                nil,
                properties.indexType,
                properties.properties()
               ) {
                self.init(url: fileURL, index: skIndex.takeUnretainedValue())
            } else {
                return nil
            }
        }

        /// Load an index from a file url
        /// - Parameter fileURL: The file URL where the index is located at
        /// - Parameter writable: Can the index be modified
        public convenience init?(fileURL: URL, writeable: Bool) {
            if let skIndex = SKIndexOpenWithURL(fileURL as CFURL, nil, writeable) {
                self.init(url: fileURL, index: skIndex.takeUnretainedValue())
            } else {
                return nil
            }
        }

        /// Open an index from a file url.
        ///
        /// - Parameters:
        ///   - fileURL: The file url to open
        ///   - writable: should the index be modifiable?
        /// - Returns: A new index object if successful, nil otherwise
        public static func openIndex(fileURL: URL, writeable: Bool) -> SearchIndexer.File? {
            if let temp = SKIndexOpenWithURL(fileURL as CFURL, nil, writeable) {
                return SearchIndexer.File(url: fileURL, index: temp.takeUnretainedValue())
            }
            return nil
        }

        /// Create an indexer using a new data container for the store
        ////
        /// - Parameters:
        ///    - fileURL: the file URL to store the index at.  url must be a non-existent file
        ///    - properties: the properties for index creation
        /// - Returns: A new index object if successful, nil otherwise. Returns nil if the file already exists at url.
        public static func create(
            fileURL: URL,
            properties: CreateProperties = CreateProperties()
        ) -> SearchIndexer.File? {
            if !FileManager.default.fileExists(atPath: fileURL.absoluteString),
               let skIndex = SKIndexCreateWithURL(
                fileURL as CFURL,
                nil,
                properties.indexType,
                properties.properties()
               ) {
                return SearchIndexer.File(url: fileURL, index: skIndex.takeUnretainedValue())
            } else {
                return nil
            }
        }

        /// Flush, compact, i.e. apply all changes and write the content of the index to the file
        public func save() {
            flush()
            compact()
        }
    }
}
