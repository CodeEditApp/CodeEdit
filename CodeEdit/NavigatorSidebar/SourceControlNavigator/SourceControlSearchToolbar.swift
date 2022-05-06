//
//  SourceControlSearchToolbar.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/05.
//

import SwiftUI
import CodeEditUI

struct SourceControlSearchToolbar: View {

    @Environment(\.colorScheme)
    var colorScheme

    @FocusState
    private var isFocused: Bool

    @Environment(\.controlActiveState)
    private var controlActive

    @State
    private var text = ""

    @ViewBuilder
    public func selectionBackground(
        _ isFocused: Bool
    ) -> some View {
        if self.controlActive != .inactive {
            if isFocused {
                if colorScheme == .light {
                    Color.white
                } else {
                    Color(hex: 0x1e1e1e)
                }
            } else {
                if colorScheme == .light {
                    Color.black.opacity(0.06)
                } else {
                    Color.white.opacity(0.24)
                }
            }
        } else {
            if colorScheme == .light {
                Color.clear
            } else {
                Color.white.opacity(0.14)
            }
        }
    }

    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundColor(.secondary)
            textField
            if !text.isEmpty { clearButton }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(selectionBackground(isFocused))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 0.5).cornerRadius(6))
    }

    private var textField: some View {
        TextField("Filter", text: $text)
            .disableAutocorrection(true)
            .textFieldStyle(PlainTextFieldStyle())
            .focused($isFocused)
    }

    private var clearButton: some View {
        Button {
            self.text = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
        }
        .foregroundColor(.secondary)
        .buttonStyle(PlainButtonStyle())
    }
}

struct SourceControlSearchToolbar_Previews: PreviewProvider {
    static var previews: some View {
        SourceControlSearchToolbar()
    }
}
