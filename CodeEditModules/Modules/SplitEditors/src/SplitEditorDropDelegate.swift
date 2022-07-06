//
//  SplitEditorDropDelegate.swift
//  CodeEditModules/SplitEditors
//
//  Created by Mateusz Bąk on 2022/07/03.
//

import Foundation
import SwiftUI

struct SplitEditorDropDelegate: DropDelegate {
    let availablePositions: [SplitEditorProposalDropPosition]
    @Binding var proposalPosition: SplitEditorProposalDropPosition?
    let geometryProxy: GeometryProxy
    let margin: CGFloat

    func performDrop(info: DropInfo) -> Bool {
        false
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        let localFrame = geometryProxy.frame(in: .local)

        if let calculatedProposalPosition = calculateDropProposalPosition(
            in: localFrame,
            for: info.location,
            margin: margin
        ), availablePositions.contains(calculatedProposalPosition) {
            proposalPosition = calculatedProposalPosition
        } else {
            proposalPosition = nil
        }

        return nil
    }

    func dropExited(info: DropInfo) {
        proposalPosition = nil
    }
}
