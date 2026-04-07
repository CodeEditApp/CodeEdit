//
//  EditorTabOnDropDelegate.swift
//  CodeEdit
//
//  Created by Austin Condiff on 9/7/23.
//

import SwiftUI

struct EditorTabOnDropDelegate: DropDelegate {
    typealias TabID = CEWorkspaceFile.ID

    private let currentTabId: TabID
    @Binding private var openedTabs: [TabID]
    @Binding private var onDragTabId: TabID?
    @Binding private var onDragLastLocation: CGPoint?
    @Binding private var isOnDragOverTabs: Bool
    @Binding private var tabWidth: [TabID: CGFloat]

    public init(
        currentTabId: TabID,
        openedTabs: Binding<[TabID]>,
        onDragTabId: Binding<TabID?>,
        onDragLastLocation: Binding<CGPoint?>,
        isOnDragOverTabs: Binding<Bool>,
        tabWidth: Binding<[TabID: CGFloat]>
    ) {
        self.currentTabId = currentTabId
        self._openedTabs = openedTabs
        self._onDragTabId = onDragTabId
        self._onDragLastLocation = onDragLastLocation
        self._isOnDragOverTabs = isOnDragOverTabs
        self._tabWidth = tabWidth
    }

    func dropEntered(info: DropInfo) {
        isOnDragOverTabs = true
        guard let onDragTabId,
              currentTabId != onDragTabId,
              let from = openedTabs.firstIndex(of: onDragTabId),
              let toIndex = openedTabs.firstIndex(of: currentTabId)
        else { return }
        if openedTabs[toIndex] != onDragTabId {
            withAnimation {
                openedTabs.move(
                    fromOffsets: IndexSet(integer: from),
                    toOffset: toIndex > from ? toIndex + 1 : toIndex
                )
            }
        }
    }

    func dropExited(info: DropInfo) {
        // Do nothing.
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        isOnDragOverTabs = false
        onDragTabId = nil
        onDragLastLocation = nil
        return true
    }
}
