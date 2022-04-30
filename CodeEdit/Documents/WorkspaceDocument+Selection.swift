//
//  WorkspaceDocument+Selection.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 30.04.22.
//

import Foundation
import WorkspaceClient
import CodeFile
import TabBar

struct WorkspaceSelectionState: Codable {

    var selectedId: TabBarItemID?
    var openedTabs: [TabBarItemID] = []

    var selected: TabBarItemRepresentable? {
        guard let selectedId = selectedId else { return nil }
        switch selectedId {
        case .codeEditor(let id):
            return openFileItems.first(where: { $0.id == id })
        }
    }

    var openFileItems: [WorkspaceClient.FileItem] = []
    var openedCodeFiles: [WorkspaceClient.FileItem: CodeFileDocument] = [:]

    enum CodingKeys: String, CodingKey {
        case selectedId, openedTabs
    }

    init() {
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedId = try container.decode(TabBarItemID?.self, forKey: .selectedId)
        openedTabs = try container.decode([TabBarItemID].self, forKey: .openedTabs)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedId, forKey: .selectedId)
        try container.encode(openedTabs, forKey: .openedTabs)
    }

    func getItemByTab(id: TabBarItemID) -> TabBarItemRepresentable? {
        switch id {
        case .codeEditor:
            return self.openFileItems.first { item in
                item.tabID == id
            }
        }
    }
}
