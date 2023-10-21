//
//  SourceControlNavigatorChangedFileView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlNavigatorChangedFileView: View {
    @ObservedObject var sourceControlManager: SourceControlManager
    var changedFile: CEWorkspaceFile

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
            Toggle("", isOn: .init(get: getSelectedFileState, set: setSelectedFile))
                .labelsHidden()

            HStack(spacing: 5) {
                Image(systemName: changedFile.systemImage)
                    .frame(width: 22)
                    .foregroundColor(changedFile.iconColor)

                Text(changedFile.name)
                    .font(.system(size: 13))

                if let folder {
                    Text(folder)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(changedFile.gitStatus?.description ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .clipShape(Rectangle())
            .onTapGesture {
                toggleSelectedFileState()
            }
        }
        .frame(height: 25)
        .contextMenu {
            Group {
                Button("View in Finder") {
                    changedFile.showInFinder()
                }
                Button("Reveal in Project Navigator") {}
                    .disabled(true) // TODO: Implementation Needed
                Divider()
            }
            Group {
                Button("Open in New Tab") {}
                    .disabled(true) // TODO: Implementation Needed
                Button("Open in New Window") {}
                    .disabled(true) // TODO: Implementation Needed
                Button("Open with External Editor") {}
                    .disabled(true) // TODO: Implementation Needed
            }
            if changedFile.gitStatus == .modified {
                Group {
                    Divider()
                    Button("Discard Changes in \(changedFile.name)...") {
                        sourceControlManager.discardChanges(for: changedFile)
                    }
                    Divider()
                }
            }
        }
        .padding(.horizontal)
    }

    func toggleSelectedFileState() {
        setSelectedFile(!getSelectedFileState())
    }

    func getSelectedFileState() -> Bool {
        return sourceControlManager.filesToCommit.contains(changedFile.id)
    }

    func setSelectedFile(_ newValue: Bool) {
        if newValue {
            sourceControlManager.filesToCommit.append(changedFile.id)
            return
        }

        guard let index = sourceControlManager.filesToCommit.firstIndex(of: changedFile.id) else {
            return
        }

        sourceControlManager.filesToCommit.remove(at: index)
    }
}
