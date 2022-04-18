//
//  HistoryInspector.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI
import GitClient

struct HistoryInspector: View {

    @ObservedObject
    private var model: HistoryInspectorModel

    /// Initialize with GitClient
    /// - Parameter gitClient: a GitClient
    init(workspaceURL: URL, fileURL: String) {
        self.model = .init(workspaceURL: workspaceURL, fileURL: fileURL)
    }

    var body: some View {
        VStack {
            List((try? model.gitClient.getCommitHistory(40, model.fileURL)) ?? [], id: \.self) { commit in
                HistoryItem(commit: commit)
            }
        }.padding(.top, 10)
    }
}
