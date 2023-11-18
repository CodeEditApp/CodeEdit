//
//  SourceControlNavigatorChangedFileView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlNavigatorChangedFileView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager
    @Binding var changedFile: CEWorkspaceFile
    @State var staged: Bool

    init(changedFile: Binding<CEWorkspaceFile>) {
        self._changedFile = changedFile
        _staged = State(initialValue: changedFile.wrappedValue.staged ?? false)
    }

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
        return relativePath.isEmpty ? nil : String(relativePath)
    }

    var body: some View {
        HStack(spacing: 5) {
            Toggle("", isOn: $staged)
                .labelsHidden()
                .onChange(of: staged) { newStaged in
                    Task {
                        if changedFile.staged != newStaged {
                            if newStaged {
                                try await sourceControlManager.add([changedFile])
                            } else {
                                try await sourceControlManager.reset([changedFile])
                            }
                        }
                    }
                }
            Image(systemName: changedFile.systemImage)
                .frame(width: 22)
                .foregroundColor(changedFile.iconColor)
            Text(changedFile.name)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Text(changedFile.gitStatus?.description ?? "")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
                .frame(minWidth: 10, alignment: .center)
        }
        .help("\(folder ?? "")\(changedFile.name)")
        .onChange(of: changedFile.staged) { newStaged in
            staged = newStaged ?? false
        }
    }
}
