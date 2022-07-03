//
//  SplitEditorDropDelegate.swift
//  CodeEditModules/SplitEditors
//
//  Created by Mateusz Bąk on 2022/07/03.
//

import Foundation
import SwiftUI

struct SplitEditorDropDelegate: DropDelegate {
    @Binding var proposalPosition: SplitEditorProposalDropPosition?
    let geometryProxy: GeometryProxy
    let margin: CGFloat

    func performDrop(info: DropInfo) -> Bool {
        false
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        let localFrame = geometryProxy.frame(in: .local)

        proposalPosition = calculateDropProposalPosition(
            in: localFrame,
            for: info.location,
            margin: margin
        )

        return nil
    }

    func dropExited(info: DropInfo) {
        proposalPosition = nil
    }
}
