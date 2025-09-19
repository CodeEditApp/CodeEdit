//
//  EditorTabView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct EditorTabView: View {

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @Environment(\.isActiveEditor)
    private var isActiveEditor

    @Environment(\.isFullscreen)
    private var isFullscreen

    @EnvironmentObject var workspace: WorkspaceDocument
    @EnvironmentObject private var editorManager: EditorManager

    @StateObject private var fileObserver: EditorTabFileObserver

    @AppSettings(\.general.fileIconStyle)
    var fileIconStyle

    /// Is cursor hovering over the entire tab.
    @State private var isHovering: Bool = false

    /// Is cursor hovering over the close button.
    @State private var isHoveringClose: Bool = false

    /// Is entire tab being pressed.
    @State private var isPressing: Bool = false

    /// Is close button being pressed.
    @State private var isPressingClose: Bool = false

    /// A bool state for going-in animation.
    ///
    /// By default, this value is `false`. When the root view is appeared, it turns `true`.
    @State private var isAppeared: Bool = false

    @State private var keyMonitor: Any?

    /// The id associating with the tab that is currently being dragged.
    ///
    /// When `nil`, then there is no tab being dragged.
    private var draggingTabId: CEWorkspaceFile.ID?

    private var onDragTabId: CEWorkspaceFile.ID?

    @Binding private var closeButtonGestureActive: Bool

    @EnvironmentObject private var editor: Editor

    /// The file item associated with the current tab.
    ///
    /// You can get tab-related information from here, like `label`, `icon`, etc.
    private let tabFile: CEWorkspaceFile

    var index: Int

    private var isTemporary: Bool {
        editor.temporaryTab?.file == tabFile
    }

    /// Is the current tab the active tab.
    private var isActive: Bool {
        tabFile == editor.selectedTab?.file
    }

    /// Is the current tab being dragged.
    private var isDragging: Bool {
        draggingTabId == tabFile.id
    }

    /// Is the current tab being held (by click and hold, not drag).
    ///
    /// I use the name `inHoldingState` to avoid any confusion with `isPressing` and `isDragging`.
    private var inHoldingState: Bool {
        isPressing || isDragging
    }

    /// Switch the active tab to current tab.
    private func switchAction() {
        // Only set the `selectedId` when they are not equal to avoid performance issue for now.
        editorManager.activeEditor = editor
        if editor.selectedTab?.file != tabFile {
            let tabItem = EditorInstance(workspace: workspace, file: tabFile)
            editor.setSelectedTab(tabFile)
            editor.clearFuture()
            editor.addToHistory(tabItem)
        }
    }

    /// Close the current tab.
    func closeAction() {
        isAppeared = false
        editor.closeTab(file: tabFile)
    }

    init(
        file: CEWorkspaceFile,
        index: Int,
        draggingTabId: CEWorkspaceFile.ID?,
        onDragTabId: CEWorkspaceFile.ID?,
        closeButtonGestureActive: Binding<Bool>
    ) {
        self.tabFile = file
        self.index = index
        self.draggingTabId = draggingTabId
        self.onDragTabId = onDragTabId
        self._closeButtonGestureActive = closeButtonGestureActive
        self._fileObserver = StateObject(wrappedValue: EditorTabFileObserver(file: file))
    }

    @ViewBuilder var content: some View {
        HStack(spacing: 0.0) {

            if #unavailable(macOS 26) {
                EditorTabDivider()
                    .opacity((isActive || inHoldingState) ? 0.0 : 1.0)
            }
            // Tab content (icon and text).
            HStack(alignment: .center, spacing: 3) {
                Image(nsImage: tabFile.nsIcon)
                    .frame(width: 16, height: 16)
                    .foregroundColor(
                        fileIconStyle == .color
                        && activeState != .inactive && isActiveEditor
                        ? tabFile.iconColor
                        : .secondary
                    )
                Text(tabFile.name)
                    .font(
                        isTemporary
                        ? .system(size: 11.0).italic()
                        : .system(size: 11.0)
                    )
                    .lineLimit(1)
                    .strikethrough(fileObserver.isDeleted, color: .primary)
            }
            .frame(maxHeight: .infinity) // To max-out the parent (tab bar) area.
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isStaticText)
            .accessibilityLabel(tabFile.name)
            .padding(.horizontal, 20)
            .overlay {
                ZStack {
                    // Close Button with is file changed indicator
                    EditorFileTabCloseButton(
                        isActive: isActive,
                        isHoveringTab: isHovering,
                        isDragging: draggingTabId != nil || onDragTabId != nil,
                        closeAction: closeAction,
                        closeButtonGestureActive: $closeButtonGestureActive,
                        item: tabFile,
                        isHoveringClose: $isHoveringClose
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .if(.tahoe) {
                $0.padding(.horizontal, 1.5)
            }
            .opacity(
                // Inactive states for tab bar item content.
                activeState != .inactive
                ? 1.0
                : isActive ? 0.6 : 0.4
            )
            if #unavailable(macOS 26) {
                EditorTabDivider()
                    .opacity((isActive || inHoldingState) ? 0.0 : 1.0)
            }
        }
        .foregroundColor(
            isActive && isActiveEditor
            ? (
                colorScheme != .dark
                ? Color(nsColor: .controlAccentColor)
                : .primary
            )
            : .primary
        )
        .frame(maxHeight: .infinity) // To vertically max-out the parent (tab bar) area.
        .contentShape(Rectangle()) // Make entire area clickable.
        .onHover { hover in
            isHovering = hover
            DispatchQueue.main.async {
                if hover {
                    NSCursor.arrow.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
        .onAppear {
            keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .otherMouseDown) { event in
                if self.isHovering && event.type == .otherMouseDown && event.buttonNumber == 2 {
                    DispatchQueue.main.async {
                        editor.closeTab(file: tabFile)
                    }
                }
                return event
            }
        }
        .onDisappear {
            if let keyMonitor = keyMonitor {
                NSEvent.removeMonitor(keyMonitor)
                self.keyMonitor = nil
            }
        }
    }

    var body: some View {
        // We don't use a button here so that accessibility isn't broken.
        content
            .background {
                EditorTabBackground(isActive: isActive, isPressing: isPressing, isDragging: isDragging)
                    .animation(.easeInOut(duration: 0.08), value: isHovering)
            }
            .if(.tahoe) {
                if #available(macOS 26, *) {
                    $0.clipShape(Capsule()).clipped().containerShape(Capsule())
                }
            }
            // TODO: Enable the following code snippet when dragging-out behavior should be allowed.
            // Since we didn't handle the drop-outside event, dragging-out is disabled for now.
            //            .onDrag({
            //                onDragTabId = item.tabID
            //                return .init(object: NSString(string: "\(item.tabID)"))
            //            })
            //        }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0) // simultaneousGesture means this won't move the view.
                    .onChanged({ _ in
                        if !isHoveringClose {
                            isPressing = true
                        }
                    })
                    .onEnded({ _ in
                        if isPressing {
                            switchAction()
                        }
                        isPressing = false
                    })
            )
            .simultaneousGesture(
                TapGesture(count: 2)
                    .onEnded { _ in
                        if isTemporary {
                            editor.temporaryTab = nil
                        }
                    }
            )
            .zIndex(isActive ? 2 : (isDragging ? 3 : (isPressing ? 1 : 0)))
            .id(tabFile.id)
            .tabBarContextMenu(item: tabFile, isTemporary: isTemporary)
            .accessibilityElement(children: .contain)
            .onAppear {
                workspace.workspaceFileManager?.addObserver(fileObserver)
            }
            .onDisappear {
                workspace.workspaceFileManager?.removeObserver(fileObserver)
            }
    }
}
