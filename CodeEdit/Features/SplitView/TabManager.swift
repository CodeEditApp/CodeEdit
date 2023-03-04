//
//  TabManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 03/03/2023.
//

import Foundation
import OrderedCollections

class TabManager: ObservableObject {
    @Published var tabGroups: TabGroup

    @Published var activeTabGroup: TabGroupData {
        didSet {
            activeTabHistory.updateOrInsert(oldValue, at: 0)
        }
    }

    var activeTabHistory: OrderedSet<TabGroupData> = []

    var fileDocuments: [WorkspaceClient.FileItem: CodeFileDocument] = [:]

    init() {
        let tab = TabGroupData()
        self.activeTabGroup = tab
        self.activeTabHistory.append(tab)
        self.tabGroups = .horizontal(.init(.horizontal, tabgroups: [.one(tab)]))
    }

    func openTab(item: WorkspaceClient.FileItem, in tabgroup: TabGroupData? = nil) {
        let tabgroup = tabgroup ?? activeTabGroup
        tabgroup.files.append(item)
        tabgroup.selected = item
        do {
            try openFile(item: item)
        } catch {
            print(error)
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
