//
//  GenericSemanticTokenStorage.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/26/24.
//

import Foundation
import LanguageServerProtocol
import CodeEditSourceEditor

/// Defines a protocol for an object to provide a storage mechanism for semantic tokens.
/// 
/// There is only one concrete type that conforms to this in CE, but this protocol is useful  in testing.
/// See ``SemanticTokenStorage`` for use.
protocol GenericSemanticTokenStorage: AnyObject {
    var lastResultId: String? { get }
    var hasTokens: Bool { get }

    init()

    func getTokensFor(range: LSPRange) -> [SemanticToken]
    func setData(_ data: borrowing SemanticTokens)
    func applyDelta(_ deltas: SemanticTokensDelta) -> [SemanticTokenRange]
}
