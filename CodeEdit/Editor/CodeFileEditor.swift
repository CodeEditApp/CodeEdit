//
//  CodeFileEditor.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 17.03.22.
//

import SwiftUI

struct CodeFileEditor: View {
    @ObservedObject var file: CodeFile
    
    var body: some View {
        EditorView(text: $file.text)
    }
}

struct CodeFileEditor_Previews: PreviewProvider {
    static var previews: some View {
        CodeFileEditor(file: .init())
    }
}
