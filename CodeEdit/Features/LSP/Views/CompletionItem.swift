//
//  CompletionItem.swift
//  CodeEdit
//
//  Created by Abe Malla on 10/05/24.
//

import SwiftUI
import CodeEditTextView
import LanguageServerProtocol
import CodeEditSourceEditor

// TODO: REMOVE Y OFFSET ON 16 PX?

// TODO: IMPORT FONT SIZE
let FONT_SIZE: CGFloat = 12
let fontSizeToImageSize: [CGFloat: CGFloat] = [
    12: 16.5,
    13: 17.75, // Not sure
    14: 19, // checking this
    16: 22,
    18: 24,
]
let fontSizeToRowHeight: [CGFloat: CGFloat] = [
    12: 21,
    13: 22,
    14: 23,
    15: 0, // TODO
    16: 26,
    17: 0, // TODO
    18: 28,
]
let fontSizeToRightPadding: [CGFloat: CGFloat] = [
    12: 13,
    13: 13,
    14: 13, // TODO
    15: 12.5,
    16: 12.5,
    17: 12.5,
    18: 12.5,
]

extension CompletionItem: @retroactive ItemBoxEntry {
    public var view: NSView {
        NSHostingView(
            rootView: HStack(spacing: 0) {
                Image(systemName: CompletionItemKind.toSymbolName(kind: self.kind))
                    .font(.system(size: fontSizeToImageSize[FONT_SIZE]!))
                    .foregroundStyle(
                        .white,
                        deprecated == true ? .gray : CompletionItemKind.toSymbolColor(kind: self.kind)
                    )
                    .padding(0)
                    .padding(.trailing, 2)

                // Main label
                HStack(spacing: 0) {
                    Text(label)
                        .font(.system(size: FONT_SIZE, design: .monospaced))
                        .foregroundStyle(deprecated == true ? .secondary : .primary)

                    if let detail = detail {
                        Text(detail)
                            .font(.system(size: FONT_SIZE, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(0)
                .offset(y: -1)

                Spacer()

                // Right side indicators
                HStack(spacing: 6.5) {
                    if deprecated == true {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: FONT_SIZE + 2))
                            .foregroundStyle(.primary, .secondary)
                    }
                    if documentation != nil {
                        Image(systemName: "chevron.right")
                            .font(.system(size: FONT_SIZE - 2.5))
                            .fontWeight(.semibold)
                    }
                }
                .padding(.leading, 4)
                .padding(.trailing, 6.5)
            }
                .padding(.horizontal, fontSizeToRightPadding[FONT_SIZE])
        )
    }
}
