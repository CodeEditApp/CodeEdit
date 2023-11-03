//
//  SourceControlSearchToolbar.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlSearchToolbar: View {

    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    private var controlActive

    @State private var text = ""

    var body: some View {
        SidebarTextField(
            "Filter",
            text: $text,
            leadingAccessories: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            },
            trailingAccessories: {
                if !text.isEmpty { clearButton }
            }
        )
//        HStack {
//            Image(systemName: "line.3.horizontal.decrease.circle")
//                .foregroundColor(.secondary)
//            textField
//            if !text.isEmpty { clearButton }
//        }
//        .padding(.horizontal, 5)
//        .padding(.vertical, 3)
//        .background(.ultraThinMaterial)
//        .clipShape(RoundedRectangle(cornerRadius: 6))
//        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 0.5).cornerRadius(6))
    }

    private var textField: some View {
        TextField("Filter", text: $text)
            .disableAutocorrection(true)
            .textFieldStyle(PlainTextFieldStyle())
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
