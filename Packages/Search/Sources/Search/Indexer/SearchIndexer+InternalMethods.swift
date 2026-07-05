//
//  SearchIndexer+InternalMethods.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 18.11.23.
//

import Foundation
import UniformTypeIdentifiers

extension SearchIndexer {
    /// A "typealias" for a document ID, using a struct because swift lint doesn't allow type-aliases for 3 types
    public struct DocumentID {
        let url: URL
        let document: SKDocument
        let documentID: SKDocumentID
    }
    /// Returns the mime type for the url, or nil if the mime type couldn't be ascertained from the extension
    ///
    /// - Parameter url: the url to detect the mime type for
    /// - Returns: the mime type of the url if able to detect, nil otherwise
    func detectMimeType(_ url: URL) -> String? {
        if let type = UTType(filenameExtension: url.pathExtension) {
            if let mimeType = type.preferredMIMEType {
                return mimeType
            }
        }
        return nil
    }

    /// Remove the given document from the index
    /// When the app deletes a document, use this function to update the index to reflect the change,
    /// i. e. the index does not need to get flushed.
    func remove(document: SKDocument) -> Bool {
        if let index = self.index {
            return modifyIndexQueue.sync {
                SKIndexRemoveDocument(index, document)
            }
        }
        return false
    }

    /// Returns the number of terms of the specified document
    private func termCount(for document: SKDocumentID) -> Int {
        guard self.index != nil else {
            return 0
        }
        return SKIndexGetDocumentTermCount(self.index!, document)
    }

    /// Is the specified document empty (ie. it has no terms)
    private func isEmpty(for document: SKDocumentID) -> Bool {
        guard self.index != nil else {
            return true // true would be the default value, i.e. document is Empty
        }
        return self.termCount(for: document) == 0
    }

    /// Recurse through the children of a document and return an array containing all the document-ids
    private func addLeafURLs(index: SKIndex, inParentDocument: SKDocument?, docs: inout [DocumentID]) {
        guard let index = self.index else {
            return
        }

        var isLeaf = true

        let iterator = SKIndexDocumentIteratorCreate(index, inParentDocument).takeRetainedValue()
        while let skDocument = SKIndexDocumentIteratorCopyNext(iterator) {
            isLeaf = false
            self.addLeafURLs(index: index, inParentDocument: skDocument.takeRetainedValue(), docs: &docs)
        }
        if isLeaf, inParentDocument != nil,
           kSKDocumentStateNotIndexed != SKIndexGetDocumentState(index, inParentDocument) {
            let url = SKDocumentCopyURL(inParentDocument).takeRetainedValue()

            let documentID = SKIndexGetDocumentID(index, inParentDocument)
            docs.append(
                DocumentID(
                    url: url as URL,
                    document: inParentDocument!,
                    documentID: documentID
                )
            )

        }
    }

    /// Return an array of all the documents contained within the index
    ///
    /// - Parameter termState: the TermState of documents to be returned (eg. all, empty only, non-empty only)
    /// - Returns: An array containing all the documents matching the TermState
    func fullDocuments(termState: TermState = .all) -> [DocumentID] {
        guard let index = self.index else {
            return []
        }

        var allDocs = [DocumentID]()

        self.addLeafURLs(index: index, inParentDocument: nil, docs: &allDocs)

        switch termState {
        case .empty:
            allDocs = allDocs.filter {
                self.isEmpty(for: $0.documentID)
            }
        case .notEmpty:
            allDocs = allDocs.filter {
                !self.isEmpty(for: $0.documentID)
            }
        default:
            break
        }

        return allDocs
    }
}
