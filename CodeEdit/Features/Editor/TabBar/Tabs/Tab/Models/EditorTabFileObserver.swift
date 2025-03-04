//
//  EditorTabFileObserver.swift
//  CodeEdit
//
//  Created by Filipp Kuznetsov on 25.02.2025.
//

import Foundation
import SwiftUI

/// Observer ViewModel for tracking file deletion
@MainActor
final class EditorTabFileObserver: ObservableObject, @preconcurrency CEWorkspaceFileManagerObserver {
    @Published private(set) var isDeleted = false

    private let tabFile: CEWorkspaceFile

    init(file: CEWorkspaceFile) {
        self.tabFile = file
    }

    func fileManagerUpdated(updatedItems: Set<CEWorkspaceFile>) {
        if let parent = tabFile.parent, updatedItems.contains(parent) {
            isDeleted = tabFile.doesExist == false
        }
    }
}
