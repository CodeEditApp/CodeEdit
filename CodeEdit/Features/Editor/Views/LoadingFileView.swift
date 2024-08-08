//
//  LoadingFileView.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/5/9.
//

import SwiftUI

/// A placeholder view that shows a spinner and text.
///
/// It optionally receives a file name.
/// ```swift
/// LoadingFileView(filename)
/// LoadingFileView()
/// ```
struct LoadingFileView: View {

    /// Name of file that is about to open.
    private var filename = ""

    init(_ filename: String = "") {
        self.filename = filename
    }

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            ProgressView()
            Text("Opening \(filename)...")
            Spacer()
        }
    }
}
