//
//  BreadcrumbsComponent.swift
//  CodeEditModules/Breadcrumbs
//
//  Created by Lukas Pistrol on 18.03.22.
//

import SwiftUI
import Combine

struct BreadcrumbsComponent: View {

    private let fileItem: WorkspaceClient.FileItem
    private let tappedOpenFile: (WorkspaceClient.FileItem) -> Void

    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    var position: NSPoint?

    @State
    var selection: WorkspaceClient.FileItem

    init(
        fileItem: WorkspaceClient.FileItem,
        tappedOpenFile: @escaping (WorkspaceClient.FileItem) -> Void
    ) {
        self.fileItem = fileItem
        self._selection = .init(wrappedValue: fileItem)
        self.tappedOpenFile = tappedOpenFile
    }

    var siblings: [WorkspaceClient.FileItem] {
        if let siblings = fileItem.parent?.children?.sortItems(foldersOnTop: true), !siblings.isEmpty {
            return siblings
        } else {
            return [fileItem]
        }
    }

    var body: some View {
        NSPopUpButtonView(selection: $selection) {
            let button = NSPopUpButton()
            button.menu = BreadcrumsMenu(fileItems: siblings, tappedOpenFile: tappedOpenFile)
            button.font = .systemFont(ofSize: NSFont.systemFontSize(for: .small))
            button.isBordered = false
            (button.cell as? NSPopUpButtonCell)?.arrowPosition = .noArrow
            return button
        }
        .padding(.leading, -5)
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
                    .sink { notification in
                        if let menuItem = notification.userInfo?["MenuItem"] as? NSMenuItem,
                           let selection = menuItem as? ItemType {
                            self.parent.selection = selection
                        }
                    }
            }
        }
    }
}
