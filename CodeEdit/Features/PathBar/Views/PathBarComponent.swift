//
//  PathBar.swift
//  CodeEditModules/PathBar
//
//  Created by Lukas Pistrol on 18.03.22.
//

import SwiftUI
import Combine

struct PathBarComponent: View {

    typealias Item = PathBarMenu.Item

    private let fileItem: Item
    private let tappedOpenFile: (File) -> Void

    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @State var position: NSPoint?

    @State var selection: Item

    init(
        fileItem: Item,
        tappedOpenFile: @escaping (File) -> Void
    ) {
        self.fileItem = fileItem
        self._selection = .init(wrappedValue: fileItem)
        self.tappedOpenFile = tappedOpenFile
    }

    var siblings: [Item] {
        // FIXME: Sort so that folders are on top
        if let siblings = fileItem.parentFolder?.children, !siblings.isEmpty {
            return siblings
        } else {
            return [fileItem]
        }
    }

    var body: some View {
        NSPopUpButtonView(selection: $selection) {
            let button = NSPopUpButton()
            button.menu = PathBarMenu(fileItems: siblings, tappedOpenFile: tappedOpenFile)
            button.font = .systemFont(ofSize: NSFont.systemFontSize(for: .small))
            button.isBordered = false
            (button.cell as? NSPopUpButtonCell)?.arrowPosition = .noArrow
            return button
        }
        .padding(.top, -0.5)
        .padding(.leading, -5)
        .padding(.trailing, -3)
    }

    struct NSPopUpButtonView<ItemType>: NSViewRepresentable {
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
                ($0.representedObject as? AnyHashable) == selection as? AnyHashable
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
