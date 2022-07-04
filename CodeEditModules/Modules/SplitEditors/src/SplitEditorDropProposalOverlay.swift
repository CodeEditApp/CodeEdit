//
//  SplitEditorDropProposalOverlay.swift
//  CodeEditModules/SplitEditors
//
//  Created by Mateusz Bąk on 2022/07/03.
//

import Foundation
import SwiftUI

struct SplitEditorDropProposalOverlay: View {
    private enum MatchedGeometryEffect {
        case overlay
    }
    @Namespace private var animation

    let proposalPosition: SplitEditorProposalDropPosition

    var body: some View {
        contentView
            .padding(4)
            .animation(.spring(), value: proposalPosition)
    }

    @ViewBuilder
    private var contentView: some View {
        switch proposalPosition {
        case .leading:
            leadingPositionOverlay
        case .trailing:
            trailingPositionOverlay
        case .top:
            topPositionOverlay
        case .bottom:
            bottomPositionOverlay
        case .center:
            centerPositionOverlay
        }
    }

    private var leadingPositionOverlay: some View {
        HStack(spacing: 0) {
            overlay
                .matchedGeometryEffect(id: MatchedGeometryEffect.overlay, in: animation)
                .transition(.identity.combined(with: .opacity))

            Color.clear
        }
    }

    private var trailingPositionOverlay: some View {
        HStack(spacing: 0) {
            Color.clear

            overlay
                .matchedGeometryEffect(id: MatchedGeometryEffect.overlay, in: animation)
                .transition(.identity.combined(with: .opacity))
        }
    }

    private var topPositionOverlay: some View {
        VStack(spacing: 0) {
            overlay
                .matchedGeometryEffect(id: MatchedGeometryEffect.overlay, in: animation)
                .transition(.identity.combined(with: .opacity))

            Color.clear
        }
    }

    private var bottomPositionOverlay: some View {
        VStack(spacing: 0) {
            Color.clear

            overlay
                .matchedGeometryEffect(id: MatchedGeometryEffect.overlay, in: animation)
                .transition(.identity.combined(with: .opacity))
        }
    }

    private var centerPositionOverlay: some View {
        overlay
            .matchedGeometryEffect(id: MatchedGeometryEffect.overlay, in: animation)
            .transition(.identity.combined(with: .opacity))
    }

    private var overlay: some View {
        ZStack {
            Color.secondary
                .cornerRadius(4)

            Image(systemName: "plus")
                .foregroundColor(Color.white)
                .font(.title)
        }
    }
}
