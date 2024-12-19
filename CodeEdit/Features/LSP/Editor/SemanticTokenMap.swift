//
//  SemanticTokenMap.swift
//  CodeEdit
//
//  Created by Khan Winter on 11/10/24.
//

import LanguageClient
import LanguageServerProtocol
import CodeEditSourceEditor
import CodeEditTextView

// swiftlint:disable line_length
/// Creates a mapping from a language server's semantic token options to a format readable by CodeEdit.
/// Provides a convenience method for mapping tokens received from the server to highlight ranges suitable for
/// highlighting in the editor.
///
/// Use this type to handle the initially received semantic highlight capabilities structures. This type will figure
/// out how to read it into a format it can use.
///
/// After initialization, the map is static until the server is reinitialized. Consequently, this type is `Sendable`
/// and immutable after initialization.
///
/// This type is not coupled to any text system via the use of the ``SemanticTokenMapRangeProvider``. When decoding to
/// highlight ranges, provide a type that can provide ranges for highlighting.
///
/// [LSP Spec](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#semanticTokensLegend)
struct SemanticTokenMap: Sendable { // swiftlint:enable line_length
    private let tokenTypeMap: [CaptureName?]
    private let modifierMap: [CaptureModifier?]

    init(semanticCapability: TwoTypeOption<SemanticTokensOptions, SemanticTokensRegistrationOptions>) {
        let legend: SemanticTokensLegend
        switch semanticCapability {
        case .optionA(let tokensOptions):
            legend = tokensOptions.legend
        case .optionB(let tokensRegistrationOptions):
            legend = tokensRegistrationOptions.legend
        }

        tokenTypeMap = legend.tokenTypes.map { CaptureName.fromString($0) }
        modifierMap = legend.tokenModifiers.map { CaptureModifier.fromString($0) }
    }

    /// Decodes the compressed semantic token data into a `HighlightRange` type for use in an editor.
    /// This is marked main actor to prevent runtime errors, due to the use of the actor-isolated `rangeProvider`.
    /// - Parameters:
    ///   - tokens: Semantic tokens from a language server.
    ///   - rangeProvider: The provider to use to translate token ranges to text view ranges.
    /// - Returns: An array of decoded highlight ranges.
    @MainActor
    func decode(tokens: SemanticTokens, using rangeProvider: SemanticTokenMapRangeProvider) -> [HighlightRange] {
        tokens.decode().compactMap { token in
            guard let range = rangeProvider.nsRangeFrom(line: token.line, char: token.char, length: token.length) else {
                return nil
            }

            let modifiers = decodeModifier(token.modifiers)

            // Capture types are indicated by the index of the set bit.
            let type = token.type > 0 ? Int(token.type.trailingZeroBitCount) : -1 // Don't try to decode 0
            let capture = tokenTypeMap.indices.contains(type) ? tokenTypeMap[type] : nil

            return HighlightRange(
                range: range,
                capture: capture,
                modifiers: modifiers
            )
        }
    }

    /// Decodes a raw modifier value into a set of capture modifiers.
    /// - Parameter raw: The raw modifier integer to decode.
    /// - Returns: A set of modifiers for highlighting.
    func decodeModifier(_ raw: UInt32) -> CaptureModifierSet {
        var modifiers: CaptureModifierSet = []
        var raw = raw
        while raw > 0 {
            let idx = raw.trailingZeroBitCount
            raw &= ~(1 << idx)
            // We don't use `[safe:]` because it creates a double optional here. If someone knows how to extend
            // a collection of optionals to make that return only a single optional this could be updated.
            guard let modifier = modifierMap.indices.contains(idx) ? modifierMap[idx] : nil else {
                continue
            }
            modifiers.insert(modifier)
        }
        return modifiers
    }
}
