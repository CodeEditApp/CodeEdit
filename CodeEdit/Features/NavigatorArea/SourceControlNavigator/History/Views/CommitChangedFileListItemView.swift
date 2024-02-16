//
//  CommitChangedFileListItemView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 12/27/23.
//

import SwiftUI

struct CommitChangedFileListItemView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager
    @Binding var changedFile: CEWorkspaceFile

    var folder: String? {
        let rootPath = sourceControlManager.gitClient.directoryURL.relativePath
        let filePath = changedFile.url.relativePath

        // Should not happen, but just in case
        if !filePath.hasPrefix(rootPath) {
            return nil
        }

        let relativePath = filePath
            .dropFirst(rootPath.count + 1) // Drop root folder
            .dropLast(changedFile.name.count + 1) // Drop file name
        return relativePath.isEmpty ? nil : "\(relativePath)/"
    }

    var body: some View {
        HStack(spacing: 6) {
            Label(title: {
                Text(changedFile.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }, icon: {
                Image(systemName: changedFile.systemImage)
                    .foregroundStyle(changedFile.iconColor)
            })

            Spacer()
            Text(changedFile.gitStatus?.description ?? "")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
                .frame(minWidth: 10, alignment: .center)
        }
        .help("\(folder ?? "")\(changedFile.name)")
    }
}
