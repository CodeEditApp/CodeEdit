//
//  ChangesView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI
import CodeEditUI
import Git

struct ChangesView: View {

    @ObservedObject
    var model: SourceControlModel

    @State
    var selectedFileID: ChangedFile.ID?

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
                List(selection: $selectedFileID) {
                    ForEach(model.changed) { file in
                        ChangedFileItemView(
                            changedFile: file,
                            selectedFileID: $selectedFileID,
                            workspaceURL: model.workspaceURL
                        )
                    }
                    .foregroundColor(.primary)
                }
                .listStyle(.automatic)
            }
        }
        .frame(maxHeight: .infinity)
    }
}
