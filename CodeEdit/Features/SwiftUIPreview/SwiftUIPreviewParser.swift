//
//  SwiftUIPreviewParser.swift
//  CodeEdit
//
//  Created by Aryan Rogye on 5/4/26.
//

import Foundation
import SwiftParser
import SwiftSyntax

struct SwiftUIPreviewSource {
    let sourceWithoutPreviews: String
    let previewBody: String
}

enum SwiftUIPreviewParser {
    static func firstPreview(in source: String) -> SwiftUIPreviewSource? {
        let tree = Parser.parse(source: source)
        let visitor = PreviewVisitor(viewMode: .sourceAccurate)
        visitor.walk(tree)

        guard let preview = visitor.previews.first else {
            return nil
        }

        let sourceWithoutPreviews = source.removingUTF8Ranges(
            visitor.previews.map(\.removalRange)
        )

        return SwiftUIPreviewSource(
            sourceWithoutPreviews: sourceWithoutPreviews,
            previewBody: preview.body.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

private final class PreviewVisitor: SyntaxVisitor {
    struct Preview {
        let body: String
        let removalRange: Range<Int>
    }

    private(set) var previews: [Preview] = []

    override func visit(_ node: MacroExpansionExprSyntax) -> SyntaxVisitorContinueKind {
        guard node.macroName.trimmedDescription == "Preview",
              let closure = node.trailingClosure else {
            return .skipChildren
        }

        previews.append(
            Preview(
                body: closure.statements.description,
                removalRange: node.position.utf8Offset..<node.endPosition.utf8Offset
            )
        )
        return .skipChildren
    }
}

private extension String {
    func removingUTF8Ranges(_ ranges: [Range<Int>]) -> String {
        guard !ranges.isEmpty else {
            return self
        }

        var bytes = Array(utf8)
        for range in ranges.sorted(by: { $0.lowerBound > $1.lowerBound }) {
            guard range.lowerBound >= bytes.startIndex, range.upperBound <= bytes.endIndex else {
                continue
            }
            bytes.removeSubrange(range)
        }

        return String(bytes: bytes, encoding: .utf8) ?? self
    }
}
