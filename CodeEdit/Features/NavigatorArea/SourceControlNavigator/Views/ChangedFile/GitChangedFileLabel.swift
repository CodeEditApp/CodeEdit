//
//  GitChangedFileLabel.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/23/24.
//

import SwiftUI

struct GitChangedFileLabel: View {
    @AppSettings(\.general.fileIconStyle)
    private var fileIconStyle
    @EnvironmentObject private var workspace: WorkspaceDocument
    @EnvironmentObject private var sourceControlManager: SourceControlManager

    let file: GitChangedFile

    var body: some View {
        HStack(spacing: 6) {
            Label {
                EmptyView()
            } icon: {
                if let ceFile = workspace.workspaceFileManager?.getFile(
                    file.fileURL.absoluteURL.path(percentEncoded: false),
                    createIfNotFound: true
                ) {
                    Image(nsImage: ceFile.nsIcon)
                        .listItemTint(iconForegroundColor(ceFile))
                } else {
                    Image(systemName: FileIcon.fileIcon(fileType: nil))
                        .listItemTint(iconForegroundColor(nil))
                }
            }

            Label {
                Text(file.fileURL.lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines))
                    .lineLimit(1)
                    .truncationMode(.middle)
            } icon: {
                EmptyView()
            }
        }
    }

    private func iconForegroundColor(_ file: CEWorkspaceFile?) -> Color {
        if fileIconStyle != .color {
            return Color("CoolGray")
        } else if let file {
            return file.iconColor
        } else {
            return FileIcon.iconColor(fileType: nil)
        }
    }
}

#Preview {
    GitChangedFileLabel(file: GitChangedFile(
        status: .modified,
        stagedStatus: .none,
        fileURL: URL(filePath: "/Users/CodeEdit/app.jsx"),
        originalFilename: nil
    ))
    .environmentObject(SourceControlManager(workspaceURL: URL(filePath: "/Users/CodeEdit"), editorManager: .init()))
    .environmentObject(WorkspaceDocument())
}

#Preview {
    GitChangedFileLabel(file: GitChangedFile(
        status: .none,
        stagedStatus: .renamed,
        fileURL: URL(filePath: "/Users/CodeEdit/app.jsx"),
        originalFilename: "app2.jsx"
    ))
    .environmentObject(SourceControlManager(workspaceURL: URL(filePath: "/Users/CodeEdit"), editorManager: .init()))
    .environmentObject(WorkspaceDocument())
}
