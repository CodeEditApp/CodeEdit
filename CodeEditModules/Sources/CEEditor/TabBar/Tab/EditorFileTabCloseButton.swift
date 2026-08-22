//
//  EditorFileTabCloseButton.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/13/23.
//

import Foundation
import CodeEditCore
import SwiftUI
import Combine

struct EditorFileTabCloseButton: View {
    var isActive: Bool
    var isHoveringTab: Bool
    var isDragging: Bool
    var closeAction: () -> Void
    @Binding var closeButtonGestureActive: Bool
    var item: CEWorkspaceFile
    @Binding var isHoveringClose: Bool

    @State private var isDocumentEdited: Bool = false
    @State private var id: Int = 0

    @EnvironmentObject private var editorManager: EditorManager

    var body: some View {
        EditorTabCloseButton(
            isActive: isActive,
            isHoveringTab: isHoveringTab,
            isDragging: isDragging,
            closeAction: closeAction,
            closeButtonGestureActive: $closeButtonGestureActive,
            isDocumentEdited: isDocumentEdited,
            isHoveringClose: $isHoveringClose
        )
        .id(id)
        // Detects if the file's document changed; when this view is created the document may be nil
        .onReceive(editorManager.documentPublisher(for: item), perform: { _ in
            // Force re-render so isDocumentEdited publisher is updated
            self.id += 1
        })
        .onReceive(
            editorManager.document(for: item)?.isDocumentEditedPublisher.eraseToAnyPublisher()
                ?? Empty().eraseToAnyPublisher()
        ) { newValue in
            self.isDocumentEdited = newValue
        }
    }
}
