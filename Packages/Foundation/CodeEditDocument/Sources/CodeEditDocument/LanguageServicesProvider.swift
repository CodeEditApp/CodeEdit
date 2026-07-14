//
//  LanguageServicesProvider.swift
//  CodeEditDocument
//
//  Created by Matthijs Eikelenboom on 2026/07/09.
//

@preconcurrency import CodeEditSourceEditor
import CodeEditTextView
import CodeEditLanguages
import AppKit

/// The per-document editor integrations supplied by a language service, such as an LSP client.
public struct LanguageServices {
    /// Keeps the document's text view in sync with the language tooling as the user edits.
    public let textCoordinator: TextViewCoordinator
    /// Supplies highlight ranges (e.g. semantic tokens) for the document's text.
    public let highlightProvider: any HighlightProviding

    /// Creates a bundle of language services from a text coordinator and a highlight provider.
    public init(textCoordinator: TextViewCoordinator, highlightProvider: any HighlightProviding) {
        self.textCoordinator = textCoordinator
        self.highlightProvider = highlightProvider
    }
}

@MainActor
public protocol LanguageServicesProvider: AnyObject {
    func languageServices(for document: CodeFileDocument) -> LanguageServices
}

public final class NoOpLanguageServicesProvider: LanguageServicesProvider {
    nonisolated public init() {}

    @MainActor
    public func languageServices(for document: CodeFileDocument) -> LanguageServices {
        LanguageServices(
            textCoordinator: NoOpTextViewCoordinator(),
            highlightProvider: NoOpHighlightProvider()
        )
    }
}

final class NoOpTextViewCoordinator: TextViewCoordinator {
    func prepareCoordinator(controller: TextViewController) {}
}

final class NoOpHighlightProvider: HighlightProviding {
    @MainActor
    func setUp(textView: TextView, codeLanguage: CodeLanguage) {}

    @MainActor
    func applyEdit(
        textView: TextView,
        range: NSRange,
        delta: Int,
        completion: @escaping @MainActor (Result<IndexSet, Error>) -> Void
    ) {
        completion(.success(IndexSet()))
    }

    @MainActor
    func queryHighlightsFor(
        textView: TextView,
        range: NSRange,
        completion: @escaping @MainActor (Result<[HighlightRange], Error>) -> Void
    ) {
        completion(.success([]))
    }
}
