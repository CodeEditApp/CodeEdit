//
//  WindowCodeFileView.swift
//  CodeEdit
//
//  Created by Khan Winter on 3/19/23.
//

import Foundation
import SwiftUI

/// View that fixes [#1158](https://github.com/CodeEditApp/CodeEdit/issues/1158)
/// # Should **not** be used other than in a single file window.
struct WindowCodeFileView: View {
    var codeFile: CodeFileDocument

    var body: some View {
        if let utType = codeFile.utType, utType.conforms(to: .text) {
            CodeFileView(codeFile: codeFile)
        } else {
            NonTextFileView(fileDocument: codeFile)
            // These are not used in single file mode, but since environment objects
            // cannot be optional, they have to be injected in the environment.
                .environmentObject(EditorManager())
                .environmentObject(StatusBarViewModel())
        }
    }
}
