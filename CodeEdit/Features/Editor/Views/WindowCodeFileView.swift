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

    @State var hasAppeared = false
    @FocusState var focused: Bool

    var body: some View {
        Group {
            if !hasAppeared {
                Color.clear.onAppear {
                    hasAppeared = true
                    focused = true
                }
            } else {
                CodeFileView(codeFile: codeFile)
                    .focused($focused)
            }
        }
    }
}
