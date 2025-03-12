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
final class EditorTabFileObserver: ObservableObject,
    CEWorkspaceFileManagerObserver
{
    @Published private(set) var isDeleted = false

    private let tabFile: CEWorkspaceFile

    init(file: CEWorkspaceFile) {
        self.tabFile = file
    }

    nonisolated func fileManagerUpdated(updatedItems: Set<CEWorkspaceFile>) {
        Task { @MainActor in
            if let parent = tabFile.parent, updatedItems.contains(parent) {
                isDeleted = tabFile.doesExist == false
            }
        }
    }
}
