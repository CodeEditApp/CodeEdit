//
//  SplitEditorDropProposalOverlay.swift
//  CodeEditModules/SplitEditors
//
//  Created by Mateusz Bąk on 2022/07/03.
//

import Foundation
import SwiftUI
import CodeEditUI

private enum Const {
    static let padding: CGFloat = 5.5
    static let animationDuration: TimeInterval = 0.2
    static let overlayCornerRadius: CGFloat = 5
    static let overlayBorderColorOpacity: CGFloat = 0.2
    static let overlayBorderLineWidth: CGFloat = 1
    static let overlayIconSize: CGFloat = 30.5
}

struct SplitEditorDropProposalOverlay: View {
    private enum MatchedGeometryEffect {
        case overlay
    }
    @Namespace private var animation

    let proposalPosition: SplitEditorProposalDropPosition

    var body: some View {
        contentView
            .padding(Const.padding)
            .animation(
                .easeInOut(duration: Const.animationDuration),
                value: proposalPosition
            )
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
            Color.clear
        }
    }

    private var trailingPositionOverlay: some View {
        HStack(spacing: 0) {
            Color.clear
            overlay
        }
    }

    private var topPositionOverlay: some View {
        VStack(spacing: 0) {
            overlay
            Color.clear
        }
    }

    private var bottomPositionOverlay: some View {
        VStack(spacing: 0) {
            Color.clear
            overlay
        }
    }

    private var centerPositionOverlay: some View {
        overlay
    }

    private var overlay: some View {
        ZStack {
            EffectView(
                .fullScreenUI,
                blendingMode: .withinWindow,
                emphasized: false
            )
            .cornerRadius(Const.overlayCornerRadius)
            .overlay {
                RoundedRectangle(cornerRadius: Const.overlayCornerRadius)
                    .stroke(
                        Color(nsColor: .secondaryLabelColor)
                            .opacity(Const.overlayBorderColorOpacity),
                        lineWidth: Const.overlayBorderLineWidth
                    )
            }
            Image(systemName: "plus")
                .foregroundColor(Color(nsColor: .secondaryLabelColor))
                .font(.system(size: Const.overlayIconSize, weight: .light))
        }
        .matchedGeometryEffect(id: MatchedGeometryEffect.overlay, in: animation)
    }
}
