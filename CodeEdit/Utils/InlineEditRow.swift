//
//  InlineEditRow.swift
//  CodeEdit
//
//  Created by Leonardo Larrañaga on 4/21/25.
//

import SwiftUI

/// A `View` for `Table` used for editing a `String` entry row.
struct InlineEditRow: View {

    let title: String
    @Binding var text: String
    @Binding var isEditing: Bool
    let onSubmit: (() -> Void)?

    init(title: String, text: Binding<String>, isEditing: Binding<Bool>, onSubmit: (() -> Void)? = nil) {
        self.title = title
        self._text = text
        self._isEditing = isEditing
        self.onSubmit = onSubmit
        self.focused = focused
        self.editedText = editedText
    }

    @FocusState private var focused: Bool

    @State var editedText: String = ""

    var body: some View {
        Group {
            if !isEditing {
                Text(text)
            } else {
                TextField(title, text: $editedText)
                    .focused($focused)
                    .onSubmit(submitText)
            }
        }
        .onChange(of: isEditing) { newValue in
            // if the user is editing, select all text
            if newValue {
                DispatchQueue.main.async {
                    focused = true
                    NSApplication.shared.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: nil)
                }
            }
        }
        .onChange(of: focused) { newValue in
            if !newValue {
                submitText()
            }
        }
        .onAppear {
            editedText = text
        }
        .onChange(of: text) { newValue in
            // Update the edited text when the original text changes
            if !isEditing {
                editedText = newValue
            }
        }
    }

    func submitText() {
        // Only update the text if the user has finished editing
        if !editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            text = editedText
        }
        isEditing = false
        onSubmit?()
    }
}

#Preview {
    struct InlineEditRowPreview: View {
        @State private var text: String = "Editable text"
        @State private var isEditing: Bool = false

        var body: some View {
            InlineEditRow(title: "Text", text: $text, isEditing: $isEditing)
                .padding(50)
                .onTapGesture {
                    isEditing = true
                }
        }
    }

    return InlineEditRowPreview()
}
