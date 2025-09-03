//
//  CodeEditWindowController+Panels.swift
//  CodeEdit
//
//  Created by Simon Kudsk on 11/05/2025.
//

import SwiftUI

extension CodeEditWindowController {
    @objc
    func objcToggleFirstPanel() {
        toggleFirstPanel(shouldAnimate: true)
    }

    /// Toggles the navigator pane, optionally without animation.
    func toggleFirstPanel(shouldAnimate: Bool = true) {
        guard let firstSplitView = splitViewController?.splitViewItems.first else { return }

        if shouldAnimate {
            // Standard animated toggle
            firstSplitView.animator().isCollapsed.toggle()
        } else {
            // Instant toggle (no animation)
            firstSplitView.isCollapsed.toggle()
        }

        splitViewController?.saveNavigatorCollapsedState(isCollapsed: firstSplitView.isCollapsed)
    }

    @objc
    func objcToggleLastPanel() {
        toggleLastPanel(shouldAnimate: true)
    }

    func toggleLastPanel(shouldAnimate: Bool = true) {
        guard let lastSplitView = splitViewController?.splitViewItems.last else {
            return
        }

        if shouldAnimate {
            // Standard animated toggle
            NSAnimationContext.runAnimationGroup { _ in
                lastSplitView.animator().isCollapsed.toggle()
            }
        } else {
            // Instant toggle (no animation)
            lastSplitView.isCollapsed.toggle()
        }

        splitViewController?.saveInspectorCollapsedState(isCollapsed: lastSplitView.isCollapsed)
    }

    // PanelDescriptor, used for an array of panels, for use with "Hide interface".
    private struct PanelDescriptor {
        /// Returns the current `isCollapsed` value for the panel.
        let isCollapsed: () -> Bool
        /// Returns the last stored previous state (or `nil` if none).
        let getPrevCollapsed: () -> Bool?
        /// Stores a new previous state (`nil` to clear).
        let setPrevCollapsed: (Bool?) -> Void
        /// Performs the actual toggle action for the panel.
        let toggle: () -> Void
    }

    // The panels which "Hide interface" should interact with.
    private var panels: [PanelDescriptor] {
        [
            PanelDescriptor(
                isCollapsed: { self.navigatorCollapsed },
                getPrevCollapsed: { self.prevNavigatorCollapsed },
                setPrevCollapsed: { self.prevNavigatorCollapsed = $0 },
                toggle: { self.toggleFirstPanel(shouldAnimate: false) }
            ),
            PanelDescriptor(
                isCollapsed: { self.inspectorCollapsed },
                getPrevCollapsed: { self.prevInspectorCollapsed },
                setPrevCollapsed: { self.prevInspectorCollapsed = $0 },
                toggle: { self.toggleLastPanel(shouldAnimate: false) }
            ),
            PanelDescriptor(
                isCollapsed: { self.workspace?.utilityAreaModel?.isCollapsed ?? true },
                getPrevCollapsed: { self.prevUtilityAreaCollapsed },
                setPrevCollapsed: { self.prevUtilityAreaCollapsed = $0 },
                toggle: { self.workspace?.utilityAreaModel?.togglePanel(animation: false) }
            ),
            PanelDescriptor(
                isCollapsed: { self.toolbarCollapsed },
                getPrevCollapsed: { self.prevToolbarCollapsed },
                setPrevCollapsed: { self.prevToolbarCollapsed = $0 },
                toggle: { self.toggleToolbar() }
            )
        ]
    }

    /// Returns `true` if at least one panel that was visible is still collapsed, meaning the interface is still hidden
    func isInterfaceStillHidden() -> Bool {
        // Some panels do not yet have a remembered state
        if panels.contains(where: { $0.getPrevCollapsed() == nil }) {
            // Hidden only if all panels are collapsed
            return panels.allSatisfy { $0.isCollapsed() }
        }

        // All panels have a remembered state. Check if any that were visible are still collapsed
        let stillHidden = panels.contains { descriptor in
            guard let prev = descriptor.getPrevCollapsed() else { return false }
            return !prev && descriptor.isCollapsed()
        }

        // If the interface has been restored, reset the remembered states
        if !stillHidden {
            DispatchQueue.main.async { [weak self] in
                self?.resetStoredInterfaceCollapseState()
            }
        }

        return stillHidden
    }

    /// Function for toggling the interface elements on or off
    ///
    /// - Parameter shouldHide: Pass `true` to hide all interface panels (and remember their current states),
    /// or `false` to restore them to how they were before hiding.
    func toggleInterface(shouldHide: Bool) {
        // Store the current layout before hiding
        if shouldHide {
            storeInterfaceCollapseState()
        }

        // Iterate over all panels and update their state as needed
        for panel in panels {
            let targetState = determineDesiredCollapseState(
                shouldHide: shouldHide,
                currentlyCollapsed: panel.isCollapsed(),
                previouslyCollapsed: panel.getPrevCollapsed()
            )
            if panel.isCollapsed() != targetState {
                panel.toggle()
            }
        }
    }

    /// Calculates the collapse state an interface element should have after a hide / show toggle.
    /// - Parameters:
    ///   - shouldHide: `true` when we’re hiding the whole interface.
    ///   - currentlyCollapsed: The panels current state
    ///   - previouslyCollapsed: The state we saved the last time we hid the UI, if any.
    /// - Returns: `true` for visible element, `false` for collapsed element
    func determineDesiredCollapseState(shouldHide: Bool, currentlyCollapsed: Bool, previouslyCollapsed: Bool?) -> Bool {
        // If ShouldHide, everything should close
        if shouldHide {
            return true
        }

        // If not hiding, and not currently collapsed, the panel should remain as such.
        if !currentlyCollapsed {
            return false
        }

        // If the panel is currently collapsed and we are "showing" or "restoring":
        // Option 1: Restore to its previously remembered state if available.
        // Option 2: If no previously remembered state, default to making it visible (not collapsed).
        return previouslyCollapsed ?? false
    }

    /// Function for storing the current interface visibility states
    func storeInterfaceCollapseState() {
        for panel in panels {
            panel.setPrevCollapsed(panel.isCollapsed())
        }
    }

    /// Function for resetting the stored interface visibility states
    func resetStoredInterfaceCollapseState() {
        for panel in panels {
            panel.setPrevCollapsed(nil)
        }
    }
}
