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
final class SemanticTokenHighlightProvider<Storage: SemanticTokenStorage>: HighlightProviding {
    enum HighlightError: Error {
        case lspRangeFailure
    }

    typealias EditCallback = @MainActor (Result<IndexSet, any Error>) -> Void

    private let tokenMap: SemanticTokenMap
    private weak var languageServer: LanguageServer?
    private weak var textView: TextView?

    private var lastEditCallback: EditCallback?
    private var storage: Storage

    var documentRange: NSRange {
        textView?.documentRange ?? .zero
    }

    init(tokenMap: SemanticTokenMap, languageServer: LanguageServer) {
        self.tokenMap = tokenMap
        self.languageServer = languageServer
        self.storage = Storage()
    }

    func documentDidChange(documentURI: String) async throws {
        guard let languageServer, let textView, let lastEditCallback else { return }

        // The document was updated. Update our cache and send the invalidated ranges for the editor to handle.
        if let lastRequestId = storage.lastRequestId {
            guard let response = try await languageServer.requestSemanticTokens( // Not sure why these are optional...
                for: documentURI,
                previousResultId: lastRequestId
            ) else {
                return
            }
            switch response {
            case let .optionA(tokenData):
                await applyEntireResponse(tokenData, callback: lastEditCallback)
            case let .optionB(deltaData):
                await applyDeltaResponse(deltaData, callback: lastEditCallback, textView: textView)
            }
        } else {
            guard let response = try await languageServer.requestSemanticTokens(for: documentURI) else {
                return
            }
            await applyEntireResponse(response, callback: lastEditCallback)
        }
    }

    func setUp(textView: TextView, codeLanguage: CodeLanguage) {
        // Send off a request to get the initial token data
        self.textView = textView
    }

    func applyEdit(textView: TextView, range: NSRange, delta: Int, completion: @escaping EditCallback) {
        if let lastEditCallback {
            lastEditCallback(.success(IndexSet())) // Don't throw a cancellation error
        }
        lastEditCallback = completion
    }

    func queryHighlightsFor(
        textView: TextView,
        range: NSRange,
        completion: @escaping @MainActor (Result<[HighlightRange], any Error>) -> Void
    ) {
        guard let lspRange = textView.lspRangeFrom(nsRange: range) else {
            completion(.failure(HighlightError.lspRangeFailure))
            return
        }
        let rawTokens = storage.getTokensFor(range: lspRange)
        let highlights = tokenMap.decode(tokens: rawTokens, using: textView)
        completion(.success(highlights))
    }

    // MARK: - Apply Response

    private func applyDeltaResponse(_ data: SemanticTokensDelta, callback: EditCallback, textView: TextView?) async {
        let lspRanges = storage.applyDelta(data, requestId: data.resultId)
        await MainActor.run {
            let ranges = lspRanges.compactMap { textView?.nsRangeFrom($0) }
            callback(.success(IndexSet(ranges: ranges)))
        }
        lastEditCallback = nil // Don't use this callback again.
    }

    private func applyEntireResponse(_ data: SemanticTokens, callback: EditCallback) async {
        storage.setData(data)
        await callback(.success(IndexSet(integersIn: documentRange)))
        lastEditCallback = nil // Don't use this callback again.
    }

}
