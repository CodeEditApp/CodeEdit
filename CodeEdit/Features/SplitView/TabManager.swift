//
//  TabManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 03/03/2023.
//

import Foundation
import OrderedCollections

class TabManager: ObservableObject {
    @Published var tabs: TabGroup

    @Published var activeTab: TabGroupData {
        didSet {
            activeTabHistory.updateOrInsert(oldValue, at: 0)
        }
    }

    var activeTabHistory: OrderedSet<TabGroupData> = []

    var fileDocuments: [WorkspaceClient.FileItem: CodeFileDocument] = [:]

    init() {
        let tab = TabGroupData()
        self.activeTab = tab
        self.activeTabHistory.append(tab)
        self.tabs = .horizontal(.init(.horizontal, tabgroups: [.one(tab)]))
    }

    func openTab(item: WorkspaceClient.FileItem) {
        Task {
            await MainActor.run {
                activeTab.files.append(item)
                activeTab.selected = item
                do {
                    try openFile(item: item)
                } catch {
                    Swift.print(error)
                }
            }
        }
    }

    private func openFile(item: WorkspaceClient.FileItem) throws {
        guard item.fileDocument == nil else {
            return
        }

        let contentType = try item.url.resourceValues(forKeys: [.contentTypeKey]).contentType
        let codeFile = try CodeFileDocument(
            for: item.url,
            withContentsOf: item.url,
            ofType: contentType?.identifier ?? ""
        )
        item.fileDocument = codeFile
        CodeEditDocumentController.shared.addDocument(codeFile)
        Swift.print("Opening file for item: ", item.url)
    }
}
