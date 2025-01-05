//
//  EditorJumpBar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 18.03.22.
//

import SwiftUI
import Combine
import CodeEditSymbols

struct EditorJumpBarComponent: View {
    private let fileItem: CEWorkspaceFile
    private let tappedOpenFile: (CEWorkspaceFile) -> Void
    private let isLastItem: Bool

    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @EnvironmentObject var workspace: WorkspaceDocument

    @State var position: NSPoint?
    @State var selection: CEWorkspaceFile
    @State var isHovering: Bool = false
    @State var button = NSPopUpButton()

    init(
        fileItem: CEWorkspaceFile,
        tappedOpenFile: @escaping (CEWorkspaceFile) -> Void,
        isLastItem: Bool
    ) {
        self.fileItem = fileItem
        self._selection = .init(wrappedValue: fileItem)
        self.tappedOpenFile = tappedOpenFile
        self.isLastItem = isLastItem
    }

    var siblings: [CEWorkspaceFile] {
        guard let fileManager = workspace.workspaceFileManager,
              let parent = fileItem.parent else {
            return [fileItem]
        }
        if let siblings = fileManager.childrenOfFile(parent), !siblings.isEmpty {
            return siblings
        } else {
            return [fileItem]
        }
    }

    var body: some View {
        NSPopUpButtonView(selection: $selection) {
            guard let fileManager = workspace.workspaceFileManager else { return NSPopUpButton() }

            button.menu = EditorJumpBarMenu(
                fileItems: siblings,
                fileManager: fileManager,
                tappedOpenFile: tappedOpenFile
            )
            button.font = .systemFont(ofSize: NSFont.systemFontSize(for: .small))
            button.isBordered = false
            (button.cell as? NSPopUpButtonCell)?.arrowPosition = .noArrow

            return button
        }
        .padding(.trailing, 11)
        .background {
            Color(nsColor: colorScheme == .dark ? .white : .black)
                .opacity(isHovering ? 0.05 : 0)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4)))
            HStack {
                Spacer()
                if isHovering {
                    chevronUpDown
                        .padding(.trailing, 4)
                } else if !isLastItem {
                    chevron
                        .padding(.trailing, 3)
                }
            }
        }
        .padding(.vertical, 3)
        .onHover { hover in
            isHovering = hover
        }
        .onLongPressGesture(minimumDuration: 0) {
            button.performClick(nil)
        }
        .opacity(activeState != .inactive ? 1 : 0.75)
    }

    private var chevron: some View {
        Image(systemName: "chevron.compact.right")
            .font(.system(size: 9, weight: activeState != .inactive ? .medium : .bold, design: .default))
            .foregroundStyle(.secondary)
            .scaleEffect(x: 1.30, y: 1.0, anchor: .center)
            .imageScale(.large)
    }

    private var chevronUpDown: some View {
        VStack(spacing: 1) {
            Image(systemName: "chevron.up")
            Image(systemName: "chevron.down")
        }
        .font(.system(size: 6, weight: .bold, design: .default))
        .padding(.top, 0.5)
    }

    struct NSPopUpButtonView<ItemType>: NSViewRepresentable where ItemType: Equatable {
        @Binding var selection: ItemType

        var popupCreator: () -> NSPopUpButton

        typealias NSViewType = NSPopUpButton

        func makeNSView(context: NSViewRepresentableContext<NSPopUpButtonView>) -> NSPopUpButton {
            let newPopupButton = popupCreator()
            setPopUpFromSelection(newPopupButton, selection: selection)
            if let menu = newPopupButton.menu {
                context.coordinator.registerForChanges(in: menu)
            }
            return newPopupButton
        }

        func updateNSView(_ nsView: NSPopUpButton, context: NSViewRepresentableContext<NSPopUpButtonView>) {
            setPopUpFromSelection(nsView, selection: selection)
        }

        func setPopUpFromSelection(_ button: NSPopUpButton, selection: ItemType) {
            let itemsList = button.itemArray
            let matchedMenuItem = itemsList.filter {
                ($0.representedObject as? ItemType) == selection
            }.first
            if matchedMenuItem != nil {
                button.select(matchedMenuItem)
            }
        }

        func makeCoordinator() -> Coordinator {
            return Coordinator(self)
        }

        class Coordinator: NSObject {
            var parent: NSPopUpButtonView

            var cancellable: AnyCancellable?

            init(_ parent: NSPopUpButtonView) {
                self.parent = parent
                super.init()
            }

            func registerForChanges(in menu: NSMenu) {
                cancellable = NotificationCenter.default
                    .publisher(for: NSMenu.didSendActionNotification, object: menu)
                    .sink { [weak self] notification in
                        if let menuItem = notification.userInfo?["MenuItem"] as? NSMenuItem,
                           let selection = menuItem as? ItemType {
                            self?.parent.selection = selection
                        }
                    }
            }
        }
    }
}
