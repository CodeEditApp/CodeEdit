//
//  CommitDetailsView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 12/27/23.
//

import SwiftUI

struct CommitDetailsView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager

    @Binding var commit: GitCommit?

    @State var commitChanges: [CEWorkspaceFile] = []

    @State var selection: CEWorkspaceFile?

    func updateCommitChanges() async throws {
        if let commit = commit {
            let changes = await sourceControlManager
                .getCommitChangedFiles(commitSHA: commit.commitHash)
            commitChanges = changes
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button {
                    commit = nil
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .buttonStyle(SidebarButtonStyle())
                Text("Commit Details")
                    .font(.system(size: 13, weight: .bold))
            }
            .padding(10)
            Divider()

            if let commit = commit {
                CommitDetailsHeaderView(commit: commit)
                    .padding(.vertical, 16)
                Divider()

                if !commitChanges.isEmpty {
                    List(selection: $selection) {
                                ForEach($commitChanges, id: \.self) { $file in
                                    CommitChangedFileListItemView(changedFile: $file)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .listRowSeparator(.hidden)
                                        .padding(.vertical, -1)
                                }

                    }
                    .environment(\.defaultMinListRowHeight, 22)
                } else {
                    CEContentUnavailableView("No Changes")
                }
            } else {
                Spacer()
            }
        }
        .onAppear {
            Task {
                try await updateCommitChanges()
            }
        }
    }
}

struct SidebarButtonStyle: ButtonStyle {
    var isActive: Bool = false

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @State var isHovering: Bool = false

    private var textOpacity: Double {
        return activeState != .inactive ? 1 : 0.3
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.body)
            .foregroundColor(configuration.isPressed ? .primary : .secondary)
            .opacity(textOpacity)
            .frame(height: 20)
            .padding(.horizontal, 5)
            .background(
                RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                    .strokeBorder(.separator, lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                            .fill(
                                Color(nsColor: colorScheme == .dark ? .white : .black)
                                    .opacity(configuration.isPressed ? 0.10 : isHovering ? 0.05 : 0)
                            )
                            .padding(1)
                    )
                    .opacity(activeState != .inactive ? 1 : 0.3)

            )
            .onHover { hover in
                isHovering = hover
            }
    }
}
