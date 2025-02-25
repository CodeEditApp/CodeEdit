//
//  EditorTabFileObserver.swift
//  CodeEdit
//
//  Created by Filipp Kuznetsov on 25.02.2025.
//

import Foundation
import SwiftUI

/// Observer ViewModel for tracking file deletion
final class EditorTabFileObserver: ObservableObject, CEWorkspaceFileManagerObserver {
    @Published private(set) var isDeleted = false

    private let item: CEWorkspaceFile

    init(item: CEWorkspaceFile) {
        self.item = item
    }

    func fileManagerUpdated(updatedItems: Set<CEWorkspaceFile>) {
        guard let parent = item.parent else {
            return
        }

        if updatedItems.contains(parent) {
            isDeleted = item.doesExist == false
        }
    }
}
