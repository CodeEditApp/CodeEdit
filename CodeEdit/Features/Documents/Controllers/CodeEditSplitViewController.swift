//
//  CodeEditSplitViewController.swift
//  CodeEdit
//
//  Created by YAPRYNTSEV Aleksey on 31.12.2022.
//

import Cocoa

private extension CGFloat {
    static let snapWidth: CGFloat = 270

    static let minSnapWidth: CGFloat = snapWidth - 10
    static let maxSnapWidth: CGFloat = snapWidth + 10
}

final class CodeEditSplitViewController: NSSplitViewController {
    // Properties
    private var isSnapped: Bool = false {
        willSet {
            if newValue, newValue != isSnapped {
                feedbackPerformer.perform(.alignment, performanceTime: .now)
            }
        }
    }

    // Dependencies
    private let feedbackPerformer: NSHapticFeedbackPerformer

    // MARK: - Initialization

    init(feedbackPerformer: NSHapticFeedbackPerformer) {
        self.feedbackPerformer = feedbackPerformer
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        splitView.setPosition(.snapWidth, ofDividerAt: .zero)
    }

    // MARK: - NSSplitViewDelegate

    override func splitView(
        _ splitView: NSSplitView,
        constrainSplitPosition proposedPosition: CGFloat,
        ofSubviewAt dividerIndex: Int
    ) -> CGFloat {
        if (CGFloat.minSnapWidth...CGFloat.maxSnapWidth).contains(proposedPosition) {
            isSnapped = true
            return .snapWidth
        } else {
            isSnapped = false
            return proposedPosition
        }
    }
}
