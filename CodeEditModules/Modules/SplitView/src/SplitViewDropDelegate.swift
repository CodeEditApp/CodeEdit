//
//  SplitViewDropDelegate.swift
//  CodeEditModules/SplitView
//
//  Created by Mateusz Bąk on 2022/07/03.
//

import Foundation
import SwiftUI

struct SplitViewDropDelegate: DropDelegate {
    let availablePositions: [SplitViewProposalDropPosition]
    @Binding var proposalPosition: SplitViewProposalDropPosition?
    let geometryProxy: GeometryProxy
    let margin: CGFloat
    let onDrop: ((SplitViewProposalDropPosition) -> Void)?

    func performDrop(info: DropInfo) -> Bool {
        if let proposalPosition = proposalPosition {
            onDrop?(proposalPosition)
        }

        return false
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
