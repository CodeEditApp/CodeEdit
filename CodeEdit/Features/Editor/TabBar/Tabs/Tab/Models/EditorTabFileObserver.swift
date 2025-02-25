//
//  EditorTabFileObserver.swift
//  CodeEdit
//
//  Created by Filipp Kuznetsov on 25.02.2025.
//

import Foundation
import SwiftUI

final class EditorTabFileObserver: ObservableObject, CEWorkspaceFileManagerObserver {
    @Published private(set) var isDeleted = false

    private let item: CEWorkspaceFile

    init(item: CEWorkspaceFile) {
        self.item = item
    }

    func fileManagerUpdated(updatedItems: Set<CEWorkspaceFile>) {
        if updatedItems.contains(item) {
            isDeleted = item.doesExist == false
        }
    }
}
