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

/// Creates a mapping from a language server's semantic token options to a format readable by CodeEdit
/// Provides a convenience method for mapping tokens received from the server to highlight ranges suitable for
/// highlighting in the editor
///
/// Use this type to handle the initially received semantic highlight capabilities structures. This type will figure
/// out how to read it into a format it can use.
///
/// After initialization, the map it static (until the server is reinitialized). Similarly, this type is `Sendable`
/// and immutable after initialization.
struct SemanticTokenMap: Sendable {
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

    @MainActor
    func convert(tokens: SemanticTokens, using textView: TextView) -> [HighlightRange] {
        tokens.decode().compactMap { token in
            guard let range = textView.nsRangeFrom(line: token.line, char: token.char, length: token.length) else {
                return nil
            }

            var modifiers: CaptureModifierSet = []
            var raw = token.modifiers
            while raw > 0 {
                let idx = raw.trailingZeroBitCount
                // We don't use `[safe:]` because it creates a double optional here. If someone knows how to extend
                // a collection of optionals to make that return only a single optional this could be updated.
                guard let modifier = modifierMap.indices.contains(idx) ? modifierMap[idx] : nil else {
                    raw &= ~(1 << raw.trailingZeroBitCount)
                    continue
                }
                modifiers.insert(modifier)
            }

            let type = Int(token.type)
            let capture = tokenTypeMap.indices.contains(type) ? tokenTypeMap[type] : nil

            return HighlightRange(
                range: range,
                capture: capture,
                modifiers: modifiers
            )
        }
    }
}
