//
//  FilterTextField.swift
//  CodeEditModules/StatusBar
//
//  Created by Stef Kors on 12/04/2022.
//

import SwiftUI

struct FilterTextField: View {
    let title: String

    @Binding
    var text: String

    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundColor(Color(nsColor: .secondaryLabelColor))
            textField
            if !text.isEmpty { clearButton }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray, lineWidth: 0.5).cornerRadius(4)
        )
    }

    private var textField: some View {
        TextField(title, text: $text)
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

struct FilterTextField_Previews: PreviewProvider {
    static var previews: some View {
        FilterTextField(title: "Filter", text: .constant(""))
        FilterTextField(title: "Filter", text: .constant("codeedi"))
    }
}
