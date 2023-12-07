//
//  FindModePicker.swift
//  CodeEdit
//
//  Created by Austin Condiff on 12/7/23.
//

import SwiftUI
import Combine

struct FindModePicker: View {
    var modes: [SearchModeModel]
    private let onSelect: (SearchModeModel) -> Void
    @Binding var selection: SearchModeModel

    private let isLastItem: Bool

    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @EnvironmentObject var workspace: WorkspaceDocument

    @State var position: NSPoint?
    @State var isHovering: Bool = false
    @State private var button: NSPopUpButton?

    init(
        modes: [SearchModeModel],
        selection: Binding<SearchModeModel>,
        onSelect: @escaping (SearchModeModel) -> Void,
        isLastItem: Bool
    ) {
        self.modes = modes
        self._selection = selection
        self.onSelect = onSelect
        self.isLastItem = isLastItem
    }

    var body: some View {
        NSPopUpButtonView(selection: $selection, isOn: selection != modes.first) {
            let button = NSPopUpButton()
            button.menu = FindModeMenu(
                modes: modes,
                onSelect: onSelect
            )
            button.font = .systemFont(ofSize: NSFont.systemFontSize(for: .small))
            button.isBordered = false
            (button.cell as? NSPopUpButtonCell)?.arrowPosition = .noArrow
            DispatchQueue.main.async {
                self.button = button
            }
            return button
        }
        .fixedSize()
        .frame(height: 21)
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
        .onTapGesture {
            button?.performClick(nil)
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
        var isOn: Bool
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
            nsView.contentTintColor = isOn ? .controlAccentColor : .controlTextColor
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

final class FindModeMenu: NSMenu, NSMenuDelegate {
    private let modes: [SearchModeModel]
    private let onSelect: (SearchModeModel) -> Void

    init(
        modes: [SearchModeModel],
        onSelect: @escaping (SearchModeModel) -> Void
    ) {
        self.modes = modes
        self.onSelect = onSelect
        super.init(title: "")
        delegate = self
        modes.forEach { mode in
            let menuItem = FindModeMenuItem(mode: mode, onSelect: onSelect)
            menuItem.onStateImage = nil
            self.addItem(menuItem)
        }
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class FindModeMenuItem: NSMenuItem {
    private let mode: SearchModeModel
    private let onSelect: (SearchModeModel) -> Void

    init(
        mode: SearchModeModel,
        onSelect: @escaping (SearchModeModel) -> Void
    ) {
        self.mode = mode
        self.onSelect = onSelect
        super.init(title: mode.title, action: #selector(handleSelect), keyEquivalent: "")
        target = self
        representedObject = mode
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    func handleSelect() {
        onSelect(mode)
    }
}
