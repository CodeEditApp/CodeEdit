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

extension CompletionItem: @retroactive ItemBoxEntry {
    public var view: NSView {
        NSHostingView(rootView: HStack(spacing: 0) {
            Image(systemName: CompletionItemKind.toSymbolName(kind: self.kind))
                .font(.system(size: 16))
                .foregroundStyle(.white, CompletionItemKind.toSymbolColor(kind: self.kind))
                .padding(0)
                .padding(.trailing, 2)

            Text(label)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(0)

            Spacer()
        })
    }
}
