//
//  EditorView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 12.03.22.
//

import SwiftUI

struct EditorView: View {
    @Binding var text: String
    
    var body: some View {
        ScrollView {
            TextEditor(text: $text)
                .disableAutocorrection(true)
                .font(.callout.monospaced())
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 31.0)
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView(text: .constant("Hello, world!"))
    }
}
