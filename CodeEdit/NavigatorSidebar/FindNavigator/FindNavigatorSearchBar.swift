//
//  SearchBar.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/21.
//

import SwiftUI

struct FindNavigatorSearchBar: View {
    @ObservedObject
    var state: WorkspaceDocument.SearchState

    let title: String

    @Binding
    var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(nsColor: .secondaryLabelColor))
            textField
            if !text.isEmpty { clearButton }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray, lineWidth: 0.5).cornerRadius(4))
    }

    private var textField: some View {
        TextField(title, text: $text)
            .disableAutocorrection(true)
            .textFieldStyle(PlainTextFieldStyle())
    }

    private var clearButton: some View {
        Button {
            self.text = ""
            state.search("")
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
