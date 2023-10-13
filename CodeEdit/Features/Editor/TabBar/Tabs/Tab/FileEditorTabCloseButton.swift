//
//  FileEditorTabCloseButton.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/13/23.
//

import Foundation
import SwiftUI
import Combine

struct FileEditorTabCloseButton: View {
    var isActive: Bool
    var isHoveringTab: Bool
    var isDragging: Bool
    var closeAction: () -> Void
    @Binding var closeButtonGestureActive: Bool
    var item: CEWorkspaceFile

    @State private var isDirty: Bool = false
    @State private var id: Int = 0

    var body: some View {
        EditorTabCloseButton(
            isActive: isActive,
            isHoveringTab: isHoveringTab,
            isDragging: isDragging,
            closeAction: closeAction,
            closeButtonGestureActive: $closeButtonGestureActive,
            isDirty: isDirty
        )
        .id(id)
        // Detects if file document changed, when this view created item.fileDocument is nil
        .onReceive(item.fileDocumentPublisher, perform: { _ in
            // Force rerender so isDirty publisher is updated
            self.id += 1
        })
        .onReceive(
            item.fileDocument?.$isDirty.eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()
        ) { newValue in
            self.isDirty = newValue
        }
    }
}
