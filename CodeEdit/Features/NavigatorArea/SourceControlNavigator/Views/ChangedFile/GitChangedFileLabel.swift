//
//  GitChangedFileLabel.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/23/24.
//

import SwiftUI

struct GitChangedFileLabel: View {
    @EnvironmentObject private var workspace: WorkspaceDocument
    @EnvironmentObject private var sourceControlManager: SourceControlManager

    let file: GitChangedFile

    var body: some View {
        Label {
            Text(file.fileURL.lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines))
                .lineLimit(1)
                .truncationMode(.middle)
        } icon: {
            if let ceFile = workspace.workspaceFileManager?.getFile(file.ceFileKey, createIfNotFound: true) {
                Image(nsImage: ceFile.nsIcon)
                    .renderingMode(.template)
            } else {
                Image(systemName: FileIcon.fileIcon(fileType: nil))
                    .renderingMode(.template)
            }
        }
    }
}

#Preview {
    Group {
        GitChangedFileLabel(file: GitChangedFile(
            status: .modified,
            stagedStatus: .none,
            fileURL: URL(filePath: "/Users/CodeEdit/app.jsx"),
            originalFilename: nil
        ))
        .environmentObject(SourceControlManager(workspaceURL: URL(filePath: "/Users/CodeEdit"), editorManager: .init()))
        .environmentObject(WorkspaceDocument())

        GitChangedFileLabel(file: GitChangedFile(
            status: .none,
            stagedStatus: .renamed,
            fileURL: URL(filePath: "/Users/CodeEdit/app.jsx"),
            originalFilename: "app2.jsx"
        ))
        .environmentObject(SourceControlManager(workspaceURL: URL(filePath: "/Users/CodeEdit"), editorManager: .init()))
        .environmentObject(WorkspaceDocument())
    }.padding()
}
