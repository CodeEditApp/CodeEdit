//
//  TabGroupData.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import Foundation
import OrderedCollections

final class TabGroupData: ObservableObject {
    @Published var files: OrderedSet<WorkspaceClient.FileItem> = []
    @Published var selected: WorkspaceClient.FileItem?

    init(files: OrderedSet<WorkspaceClient.FileItem> = [], selected: WorkspaceClient.FileItem? = nil) {
        self.files = files
        self.selected = selected
    }
}
