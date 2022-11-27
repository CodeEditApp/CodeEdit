//
//  ChangesView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct ChangesView: View {

    @ObservedObject
    var model: SourceControlModel

    @State
    var selectedFile: ChangedFile.ID?

    /// Initialize with GitClient
    /// - Parameter gitClient: a GitClient
    init(workspaceURL: URL) {
        self.model = .init(workspaceURL: workspaceURL)
    }

    var body: some View {
        VStack(alignment: .center) {
            if model.changed.isEmpty {
                Text("No Changes")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            } else {
                List(selection: $selectedFile) {
                    Section("Local Changes") {
                        ForEach(model.changed) { file in
                            ChangedFileItemView(changedFile: file,
                                                selection: $selectedFile,
                                                workspaceURL: model.workspaceURL)
                        }
                    }
                    .foregroundColor(.secondary)
                }
                .listStyle(.sidebar)
            }
        }
        .frame(maxHeight: .infinity)
    }
}
