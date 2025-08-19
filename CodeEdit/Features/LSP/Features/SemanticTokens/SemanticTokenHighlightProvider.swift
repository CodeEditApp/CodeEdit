//
//  SemanticTokenHighlightProvider.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/26/24.
//

import Foundation
import LanguageServerProtocol
import CodeEditSourceEditor
import CodeEditTextView
import CodeEditLanguages

/// Provides semantic token information from a language server for a source editor view.
///
/// This class works in tangent with the ``LanguageServer`` class to ensure we don't unnecessarily request new tokens
/// if the document isn't updated. The ``LanguageServer`` will call the
/// ``SemanticTokenHighlightProvider/documentDidChange`` method, which in turn refreshes the semantic token storage.
///
/// That behavior may not be intuitive due to the
/// ``SemanticTokenHighlightProvider/applyEdit(textView:range:delta:completion:)`` method. One might expect this class
/// to respond to that method immediately, but it does not. It instead stores the completion passed in that method until
/// it can respond to the edit with invalidated indices.
final class SemanticTokenHighlightProvider<
    Storage: GenericSemanticTokenStorage,
    DocumentType: LanguageServerDocument
>: HighlightProviding {
    enum HighlightError: Error {
        case lspRangeFailure
    }

    typealias EditCallback = @MainActor (Result<IndexSet, any Error>) -> Void
    typealias HighlightCallback = @MainActor (Result<[HighlightRange], any Error>) -> Void

    private var tokenMap: SemanticTokenMap?
    private var documentURI: String?
    weak var languageServer: LanguageServer<DocumentType>?
    private weak var textView: TextView?

    private var lastEditCallback: EditCallback?
    private var pendingHighlightCallbacks: [HighlightCallback] = []
    private var storage: Storage

    var documentRange: NSRange {
        textView?.documentRange ?? .zero
    }

    init(
        tokenMap: SemanticTokenMap? = nil,
        languageServer: LanguageServer<DocumentType>? = nil,
        documentURI: String? = nil
    ) {
        self.tokenMap = tokenMap
        self.languageServer = languageServer
        self.documentURI = documentURI
        self.storage = Storage()
    }

    func setUp(server: LanguageServer<DocumentType>, document: DocumentType) {
        languageServer = server
        documentURI = document.languageServerURI
        tokenMap = server.highlightMap
    }

    // MARK: - Language Server Content Lifecycle

    /// Called when the language server finishes sending a document update.
    ///
    /// This method first checks if this object has any semantic tokens. If not, requests new tokens and responds to the
    /// `pendingHighlightCallbacks` queue with cancellation errors, causing the highlighter to re-query those indices.
    ///
    /// If this object already has some tokens, it determines whether or not we can request a token delta and
    /// performs the request.
    func documentDidChange() async throws {
        guard let languageServer, let textView else {
            return
        }

        guard storage.hasReceivedData else {
            // We have no semantic token info, request it!
            try await requestTokens(languageServer: languageServer, textView: textView)
            await MainActor.run {
                for callback in pendingHighlightCallbacks {
                    callback(.failure(HighlightProvidingError.operationCancelled))
                }
                pendingHighlightCallbacks.removeAll()
            }
            return
        }

        // The document was updated. Update our token cache and send the invalidated ranges for the editor to handle.
        if let lastResultId = storage.lastResultId {
            try await requestDeltaTokens(languageServer: languageServer, textView: textView, lastResultId: lastResultId)
            return
        }

        try await requestTokens(languageServer: languageServer, textView: textView)
    }

    // MARK: - LSP Token Requests

    /// Requests and applies a token delta. Requires a previous response identifier.
    private func requestDeltaTokens(
        languageServer: LanguageServer<DocumentType>,
        textView: TextView,
        lastResultId: String
    ) async throws {
        guard let documentURI,
              let response = try await languageServer.requestSemanticTokens(
            for: documentURI,
            previousResultId: lastResultId
        ) else {
            return
        }
        switch response {
        case let .optionA(tokenData):
            await applyEntireResponse(tokenData, callback: lastEditCallback)
        case let .optionB(deltaData):
            await applyDeltaResponse(deltaData, callback: lastEditCallback, textView: textView)
        }
    }

    /// Requests and applies tokens for an entire document. This does not require a previous response id, and should be
    /// used in place of `requestDeltaTokens` when that's the case.
    private func requestTokens(languageServer: LanguageServer<DocumentType>, textView: TextView) async throws {
        guard let documentURI, let response = try await languageServer.requestSemanticTokens(for: documentURI) else {
            return
        }
        await applyEntireResponse(response, callback: lastEditCallback)
    }

    // MARK: - Apply LSP Response

    /// Applies a delta response from the LSP to our storage.
    private func applyDeltaResponse(_ data: SemanticTokensDelta, callback: EditCallback?, textView: TextView?) async {
        let lspRanges = storage.applyDelta(data)
        lastEditCallback = nil // Don't use this callback again.
        await MainActor.run {
            let ranges = lspRanges.compactMap { textView?.nsRangeFrom($0) }
            callback?(.success(IndexSet(ranges: ranges)))
        }
    }

    private func applyEntireResponse(_ data: SemanticTokens, callback: EditCallback?) async {
        storage.setData(data)
        lastEditCallback = nil // Don't use this callback again.
        await callback?(.success(IndexSet(integersIn: documentRange)))
    }

    // MARK: - Highlight Provider Conformance

    func setUp(textView: TextView, codeLanguage: CodeLanguage) {
        // Send off a request to get the initial token data
        self.textView = textView
        Task {
            try await self.documentDidChange()
        }
    }

    func applyEdit(textView: TextView, range: NSRange, delta: Int, completion: @escaping EditCallback) {
        if let lastEditCallback {
            lastEditCallback(.success(IndexSet())) // Don't throw a cancellation error
        }
        lastEditCallback = completion
    }

    func queryHighlightsFor(textView: TextView, range: NSRange, completion: @escaping HighlightCallback) {
        guard storage.hasReceivedData else {
            pendingHighlightCallbacks.append(completion)
            return
        }

        guard let lspRange = textView.lspRangeFrom(nsRange: range), let tokenMap else {
            completion(.failure(HighlightError.lspRangeFailure))
            return
        }
        let rawTokens = storage.getTokensFor(range: lspRange)
        let highlights = tokenMap
            .decode(tokens: rawTokens, using: textView)
            .compactMap { highlightRange -> HighlightRange? in
                // Filter out empty ranges
                guard highlightRange.capture != nil || !highlightRange.modifiers.isEmpty,
                      // Clamp the highlight range to the queried range.
                      let intersection = highlightRange.range.intersection(range),
                      intersection.isEmpty == false else {
                    return nil
                }
                return HighlightRange(
                    range: intersection,
                    capture: highlightRange.capture,
                    modifiers: highlightRange.modifiers
                )
            }
        completion(.success(highlights))
    }
}
