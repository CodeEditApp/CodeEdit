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
import Factory

public struct LanguageServices {
    public let textCoordinator: TextViewCoordinator
    public let highlightProvider: any HighlightProviding

    public init(textCoordinator: TextViewCoordinator, highlightProvider: any HighlightProviding) {
        self.textCoordinator = textCoordinator
        self.highlightProvider = highlightProvider
    }
}

extension Container {
    public var languageServicesProvider: Factory<LanguageServicesProvider> {
        self { @MainActor in NoOpLanguageServicesProvider() }.singleton
    }
}

@MainActor
public protocol LanguageServicesProvider: AnyObject {
    func languageServices(for document: CodeFileDocument) -> LanguageServices
}

public final class NoOpLanguageServicesProvider: LanguageServicesProvider {
    public init() {}

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
