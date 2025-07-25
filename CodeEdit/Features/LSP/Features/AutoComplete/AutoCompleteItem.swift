//
//  AutoCompleteItem.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/25/25.
//

import SwiftUI
import CodeEditSourceEditor
import LanguageServerProtocol

/// A Near 1:1 of `LanguageServerProtocol`'s `CompletionItem`. Wrapped for compatibility with the CESE's
/// `CodeSuggestionEntry` protocol to deal with some optional bools.
struct AutoCompleteItem: Hashable, Sendable, CodeSuggestionEntry {
    let label: String
    let kind: CompletionItemKind?
    let detail: String?
    let documentation: TwoTypeOption<String, MarkupContent>?
    let deprecated: Bool
    let preselect: Bool
    let sortText: String?
    let filterText: String?
    let insertText: String?
    let insertTextFormat: InsertTextFormat?
    let textEdit: TwoTypeOption<TextEdit, InsertReplaceEdit>?
    let additionalTextEdits: [TextEdit]?
    let commitCharacters: [String]?
    let command: LanguageServerProtocol.Command?
    let data: LSPAny?

    // Not used by regular autocomplete items
    public var pathComponents: [String]? { nil }
    public var targetPosition: CursorPosition? { nil }

    // LSP Spec says the `detail` field holds useful syntax information about the item for completion.
    public var sourcePreview: String? { detail }

    public var image: Image { Image(systemName: kind?.symbolName ?? "dot.square.fill") }
    public var imageColor: SwiftUI.Color { kind?.swiftUIColor ?? SwiftUI.Color.gray }

    init(_ item: CompletionItem) {
        self.label = item.label
        self.kind = item.kind
        self.detail = item.detail
        self.documentation = item.documentation
        self.deprecated = item.deprecated ?? false
        self.preselect = item.preselect ?? false
        self.sortText = item.sortText
        self.filterText = item.filterText
        self.insertText = item.insertText
        self.insertTextFormat = item.insertTextFormat
        self.textEdit = item.textEdit
        self.additionalTextEdits = item.additionalTextEdits
        self.commitCharacters = item.commitCharacters
        self.command = item.command
        self.data = item.data
    }
}
