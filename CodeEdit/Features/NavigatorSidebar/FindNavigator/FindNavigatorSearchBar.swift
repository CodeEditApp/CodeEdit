//
//  SearchBar.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/21.
//

import SwiftUI

struct FindNavigatorSearchBar: View {
    @Environment(\.colorScheme)
    var colorScheme

    @ObservedObject
    private var state: WorkspaceDocument.SearchState

    @FocusState
    private var isFocused: Bool

    private let title: String

    @Binding
    private var text: String

    @Environment(\.controlActiveState)
    private var controlActive

    @ViewBuilder
    public func selectionBackground(
        _ isFocused: Bool = false
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

    init(state: WorkspaceDocument.SearchState,
         title: String,
         text: Binding<String>) {
        self.state = state
        self.title = title
        self._text = text
    }

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(nsColor: .secondaryLabelColor))
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
        TextField(title, text: $text)
            .disableAutocorrection(true)
            .textFieldStyle(PlainTextFieldStyle())
            .focused($isFocused)
    }

    private var clearButton: some View {
        Button {
            self.text = ""
            state.search(nil)
        } label: {
            Image(systemName: "xmark.circle.fill")
        }
        .foregroundColor(.secondary)
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            FindNavigatorSearchBar(
                state: .init(WorkspaceDocument.init()),
                title: "placeholder",
                text: .constant("value")
            )
        }
        .padding()
    }
}
