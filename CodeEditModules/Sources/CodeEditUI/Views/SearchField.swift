//
//  SearchField.swift
//  CodeEdit
//
//  Created by Austin Condiff on 9/3/24.
//

import SwiftUI

public struct SearchField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String

    public init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField()
        searchField.delegate = context.coordinator
        searchField.placeholderString = placeholder
        return searchField
    }

    public func updateNSView(_ nsView: NSSearchField, context: Context) {
        nsView.stringValue = text
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: SearchField

        init(_ parent: SearchField) {
            self.parent = parent
        }

        public func controlTextDidChange(_ obj: Notification) {
            if let searchField = obj.object as? NSSearchField {
                parent.text = searchField.stringValue
            }
        }
    }
}

#Preview {
    SearchField("Search", text: .constant("Test"))
}
