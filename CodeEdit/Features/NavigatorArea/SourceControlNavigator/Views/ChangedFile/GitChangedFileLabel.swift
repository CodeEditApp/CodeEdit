//
//  GitChangedFileLabel.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/23/24.
//

import CESourceControl
import SwiftUI
import ShellClient
import CEWorkspaceFileManager
import CodeEditCore

struct GitChangedFileLabel: View {
    @EnvironmentObject private var sourceControlManager: SourceControlManager

    @Environment(\.workspaceFileManager)
    private var workspaceFileManager

    let file: GitChangedFile

    var body: some View {
        Label {
            Text(file.fileURL.lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines))
                .lineLimit(1)
                .truncationMode(.middle)
        } icon: {
            if let ceFile = workspaceFileManager?.getFile(file.ceFileKey, createIfNotFound: true) {
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
        .environmentObject(SourceControlManager(workspaceURL: URL(filePath: "/Users/CodeEdit"), shellClient: ShellClient(), eventBus: EventBus()))

        GitChangedFileLabel(file: GitChangedFile(
            status: .none,
            stagedStatus: .renamed,
            fileURL: URL(filePath: "/Users/CodeEdit/app.jsx"),
            originalFilename: "app2.jsx"
        ))
        .environmentObject(SourceControlManager(workspaceURL: URL(filePath: "/Users/CodeEdit"), shellClient: ShellClient(), eventBus: EventBus()))
    }.padding()
}
