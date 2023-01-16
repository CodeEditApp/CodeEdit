//
//  CodeEditSplitViewController.swift
//  CodeEdit
//
//  Created by YAPRYNTSEV Aleksey on 31.12.2022.
//

import Cocoa

private extension CGFloat {
    static let snapWidth: CGFloat = 272

    static let minSnapWidth: CGFloat = snapWidth - 10
    static let maxSnapWidth: CGFloat = snapWidth + 10
}

final class CodeEditSplitViewController: NSSplitViewController {
    private var workspace: WorkspaceDocument
    private let widthStateName: String = "\(String(describing: CodeEditSplitViewController.self))-Width"
    private var setWidthFromState = false

    // Properties
    private(set) var isSnapped: Bool = false {
        willSet {
            if newValue, newValue != isSnapped {
                feedbackPerformer.perform(.alignment, performanceTime: .now)
            }
        }
    }

    // Dependencies
    private let feedbackPerformer: NSHapticFeedbackPerformer

    // MARK: - Initialization

    init(workspace: WorkspaceDocument, feedbackPerformer: NSHapticFeedbackPerformer) {
        self.workspace = workspace
        self.feedbackPerformer = feedbackPerformer
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        let width = workspace.getFromWorkspaceState(key: self.widthStateName) as? CGFloat ?? 0
        splitView.setPosition(width, ofDividerAt: .zero)
        setWidthFromState = true
    }

    // MARK: - NSSplitViewDelegate

    override func splitView(
        _ splitView: NSSplitView,
        constrainSplitPosition proposedPosition: CGFloat,
        ofSubviewAt dividerIndex: Int
    ) -> CGFloat {
        if dividerIndex == 0 {
            // Navigator
            if (CGFloat.minSnapWidth...CGFloat.maxSnapWidth).contains(proposedPosition) {
                isSnapped = true
                return .snapWidth
            } else {
                isSnapped = false
                if proposedPosition <= CodeEditWindowController.minSidebarWidth / 2 {
                    splitViewItems.first?.isCollapsed = true
                    return 0
                }
                return max(CodeEditWindowController.minSidebarWidth, proposedPosition)
            }
        } else if dividerIndex == 1 {
            let proposedWidth = view.frame.width - proposedPosition
            if proposedWidth <= CodeEditWindowController.minSidebarWidth / 2 {
                splitViewItems.last?.isCollapsed = true
                removeToolbarItemIfNeeded()
                return proposedPosition
            }
            splitViewItems.last?.isCollapsed = false
            insertToolbarItemIfNeeded()
            return min(view.frame.width - CodeEditWindowController.minSidebarWidth, proposedPosition)
        }
        return proposedPosition
    }

    override func splitViewDidResizeSubviews(_ notification: Notification) {
        guard let resizedDivider = notification.userInfo?["NSSplitViewDividerIndex"] as? Int else {
            return
        }

        if resizedDivider == 0 {
            let panel = splitView.subviews[0]
            let width = panel.frame.size.width
            if width > 0 && setWidthFromState {
                workspace.addToWorkspaceState(key: self.widthStateName, value: width)
            }
        }
    }

    /// Quick fix for list tracking separator needing to be added again after closing,
    /// then opening the inspector with a drag.
    private func insertToolbarItemIfNeeded() {
        guard !(
            view.window?.toolbar?.items.contains(where: { $0.itemIdentifier == .itemListTrackingSeparator }) ?? true
        ) else {
            return
        }
        view.window?.toolbar?.insertItem(withItemIdentifier: .itemListTrackingSeparator, at: 4)
    }

    /// Quick fix for list tracking separator needing to be removed after closing the inspector with a drag
    private func removeToolbarItemIfNeeded() {
        guard let index = view.window?.toolbar?.items.firstIndex(
                where: { $0.itemIdentifier == .itemListTrackingSeparator }
              ) else {
            return
        }
        view.window?.toolbar?.removeItem(at: index)
    }
}
