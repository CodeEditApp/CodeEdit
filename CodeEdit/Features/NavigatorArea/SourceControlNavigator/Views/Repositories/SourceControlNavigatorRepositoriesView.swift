//
//  SourceControlNavigatorRepositoriesView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI
import CodeEditSymbols

struct RepoOutlineGroupItem: Hashable {
    var label: String
    var description: String?
    var systemImage: String?
    var symbolImage: String?
    var imageColor: Color?
    var children: [RepoOutlineGroupItem]?
    var branch: GitBranch?
}

struct SourceControlNavigatorRepositoriesView: View {
    @Environment(\.controlActiveState)
    var controlActiveState

    @EnvironmentObject var sourceControlManager: SourceControlManager

    @State var selection = Set<RepoOutlineGroupItem>()
    @State var showNewBranch: Bool = false
    @State var fromBranch: GitBranch?

    var data: [RepoOutlineGroupItem] {
        [
            RepoOutlineGroupItem(
                label: "Branches",
                systemImage: "externaldrive.fill",
                imageColor: Color(nsColor: .secondaryLabelColor),
                children: sourceControlManager.branches.filter({ $0.isLocal }).map { branch in
                    RepoOutlineGroupItem(
                        label: branch.name,
                        description: branch == sourceControlManager.currentBranch ? "(current)" : nil,
                        symbolImage: "commit",
                        imageColor: .blue,
                        branch: branch
                    )
                }
            ),
            RepoOutlineGroupItem(
                label: "Stashed Changes",
                systemImage: "tray.2.fill",
                imageColor: Color(nsColor: .secondaryLabelColor),
                children: sourceControlManager.stashEntries.map { stashEntry in
                    RepoOutlineGroupItem(label: stashEntry.message, systemImage: "tray", imageColor: .orange)
                }
            ),
            RepoOutlineGroupItem(
                label: "Remotes",
                systemImage: "network",
                imageColor: Color(nsColor: .secondaryLabelColor),
                children: sourceControlManager.remotes.map { remote in
                    RepoOutlineGroupItem(label: remote.name, symbolImage: "vault", imageColor: .teal)
                }
            )
        ]
    }

    var body: some View {
        List(selection: $selection) {
            OutlineGroup(data, id: \.self, children: \.children) { item in
                if item.systemImage != nil || item.symbolImage != nil {
                    Label(title: {
                        Text(item.label)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        if let description = item.description {
                            Text(description)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .foregroundStyle(.secondary)
                                .font(.system(size: 11))
                        }
                    }, icon: {
                        if item.symbolImage != nil {
                            Image(symbol: item.symbolImage ?? "")
                                .foregroundStyle(item.imageColor ?? .accentColor)
                                .opacity(controlActiveState == .inactive ? 0.5 : 1)
                        } else {
                            Image(systemName: item.systemImage ?? "")
                                .foregroundStyle(item.imageColor ?? .accentColor)
                                .opacity(controlActiveState == .inactive ? 0.5 : 1)
                        }
                    })
                    .padding(.leading, 2)
                } else {
                    Text(item.label)
                }
            }
            .listRowSeparator(.hidden)
        }
        .sheet(isPresented: $showNewBranch, content: {
            SourceControlNavigatorNewBranchView(
                sourceControlManager: sourceControlManager,
                fromBranch: fromBranch
            )
        })
        .contextMenu(
            forSelectionType: RepoOutlineGroupItem.self,
            menu: { items in
                if !items.isEmpty,
                   items.count == 1,
                   let item = items.first,
                   let branch = item.branch ?? sourceControlManager.currentBranch {
                    Button("Checkout") {
                        Task {
                            do {
                                try await sourceControlManager.checkoutBranch(branch: branch)
                            } catch {
                                await sourceControlManager.showAlertForError(title: "Failed to checkout", error: error)
                            }
                        }
                    }
                    .disabled(item.branch == nil || sourceControlManager.currentBranch == item.branch)
                    Divider()
                    Button("New Branch from \"\(branch.name)\"") {
                        showNewBranch = true
                        fromBranch = item.branch
                    }
                    Divider()
                    Button("Delete...") {
                        Task {
                            do {
                                try await sourceControlManager.deleteBranch(branch: branch)
                            } catch {
                                await sourceControlManager.showAlertForError(title: "Failed to delete", error: error)
                            }
                        }
                    }
                    .disabled(
                        item.branch == nil
                        || item.branch?.isLocal == false
                        || sourceControlManager.currentBranch == item.branch
                    )
                }
            }
        )
        .frame(maxHeight: .infinity)
        .task {
            await sourceControlManager.refreshBranches()
        }
    }
}
