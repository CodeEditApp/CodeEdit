//
//  SourceControlNavigatorRepositoriesView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI
import CodeEditSymbols

struct RepoOutlineGroupItem: Hashable, Identifiable {
    var id: String
    var label: String
    var description: String?
    var systemImage: String?
    var symbolImage: String?
    var imageColor: Color?
    var children: [RepoOutlineGroupItem]?
    var branch: GitBranch?
}

struct SourceControlNavigatorRepositoriesItem: View {
    let item: RepoOutlineGroupItem

    @Environment(\.controlActiveState)
    var controlActiveState

    var body: some View {
        if item.systemImage != nil || item.symbolImage != nil {
            Label(title: {
                Text(item.label)
                    .lineLimit(1)
                    .truncationMode(.middle)
                if let description = item.description {
                    Text(description)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 11))
                }
            }, icon: {
                if item.symbolImage != nil {
                    Image(symbol: item.symbolImage ?? "")
                        .opacity(controlActiveState == .inactive ? 0.5 : 1)
                } else {
                    Image(systemName: item.systemImage ?? "")
                        .opacity(controlActiveState == .inactive ? 0.5 : 1)
                }
            })
            .accentColor(item.imageColor ?? .accentColor)
            .padding(.leading, 1)
            .padding(.vertical, -1)
        } else {
            Text(item.label)
                .padding(.leading, 2)

        }
    }
}

struct SourceControlNavigatorRepositoriesView: View {
    @Environment(\.controlActiveState)
    var controlActiveState

    @EnvironmentObject var sourceControlManager: SourceControlManager

    @State var selection = Set<String>()
    @State var showNewBranch: Bool = false
    @State var fromBranch: GitBranch?
    @State var expandedIds = [String: Bool]()

    var data: [RepoOutlineGroupItem] {
        [
            .init(
                id: "BranchesGroup",
                label: "Branches",
                systemImage: "externaldrive.fill",
                imageColor: Color(nsColor: .secondaryLabelColor),
                children: sourceControlManager.branches.filter({ $0.isLocal }).map { branch in
                    .init(
                        id: "Branch\(branch.name)",
                        label: branch.name,
                        description: branch == sourceControlManager.currentBranch ? "(current)" : nil,
                        symbolImage: "branch",
                        imageColor: .blue,
                        branch: branch
                    )
                }
            ),
            .init(
                id: "StashedChangesGroup",
                label: "Stashed Changes",
                systemImage: "tray.2.fill",
                imageColor: Color(nsColor: .secondaryLabelColor),
                children: sourceControlManager.stashEntries.map { stashEntry in
                    .init(
                        id: "StashEntry\(stashEntry.hashValue)",
                        label: stashEntry.message,
                        description: stashEntry.date.formatted(
                            Date.FormatStyle()
                                .year(.defaultDigits)
                                .month(.abbreviated)
                                .day(.twoDigits)
                                .hour(.defaultDigits(amPM: .abbreviated))
                                .minute(.twoDigits)
                        ),
                        systemImage: "tray",
                        imageColor: .orange
                    )
                }
            ),
            .init(
                id: "RemotesGroup",
                label: "Remotes",
                systemImage: "network",
                imageColor: Color(nsColor: .secondaryLabelColor),
                children: sourceControlManager.remotes.map { remote in
                    .init(
                        id: "Remote\(remote.hashValue)",
                        label: remote.name,
                        symbolImage: "vault",
                        imageColor: .teal
                    )
                }
            )
        ]
    }

    func findItem(by id: String, in items: [RepoOutlineGroupItem]) -> RepoOutlineGroupItem? {
        for item in items {
            if item.id == id {
                return item
            } else if let children = item.children, let found = findItem(by: id, in: children) {
                return found
            }
        }
        return nil
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(data, id: \.id) { item in
                CEOutlineGroup(
                    item,
                    id: \.id,
                    defaultExpanded: true,
                    expandedIds: $expandedIds,
                    children: \.children,
                    content: { item in
                        SourceControlNavigatorRepositoriesItem(item: item)
                    }
                )
                .listRowSeparator(.hidden)
            }
        }
        .environment(\.defaultMinListRowHeight, 22)
        .sheet(isPresented: $showNewBranch, content: {
            SourceControlNavigatorNewBranchView(
                sourceControlManager: sourceControlManager,
                fromBranch: fromBranch
            )
        })
        .contextMenu(
            forSelectionType: RepoOutlineGroupItem.ID.self,
            menu: { items in
                if !items.isEmpty,
                   items.count == 1,
                   let item = findItem(by: items.first ?? "", in: data),
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
