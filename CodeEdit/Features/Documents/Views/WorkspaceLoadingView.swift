//
//  WorkspaceLoadingView.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/5/9.
//

import SwiftUI

/// A placeholder view that shows a spinner and label.
///
/// Examples:
/// ```swift
/// WorkspaceLoadingView("ContentView.swift")
/// WorkspaceLoadingView(filename)
/// ```
struct WorkspaceLoadingView: View {

    /// Name of file that is about to open.
    private var filename = ""

    init(_ filename: String = "") {
        self.filename = filename
    }

    var body: some View {
        VStack(spacing: 10) {
            ProgressView()
            Text("Opening \(filename)...")
        }
    }
}
