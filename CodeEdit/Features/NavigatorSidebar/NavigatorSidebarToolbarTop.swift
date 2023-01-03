//
//  SideBarToolbar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import CodeEditSymbols

struct NavigatorSidebarToolbarTop: View {
    @Environment(\.controlActiveState)
    private var activeState

    @Binding
    var selection: SidebarNavigator

    @State private var hasChangedLocation: Bool = false
    @State private var draggingItem: SidebarNavigator?
    @State private var drugItemLocation: CGPoint?
    @State private var icons = SidebarNavigator.allCases

    var body: some View {
        HStack(spacing: 2) {
            ForEach(icons) { icon in
                makeIcon(icon: icon)
                    .opacity(draggingItem?.id == icon.id &&
                             hasChangedLocation &&
                             drugItemLocation != nil ? 0.0 : 1.0)
                    .onDrop(of: [.utf8PlainText],
                            delegate: NavigatorSidebarDockIconDelegate(item: icon,
                                                                        current: $draggingItem,
                                                                        icons: $icons,
                                                                        hasChangedLocation: $hasChangedLocation,
                                                                        drugItemLocation: $drugItemLocation))
//                    .disabled(icon.disabled)
            }
        }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Divider()
        }
        .overlay(alignment: .bottom) {
            Divider()
        }
        .animation(.default, value: icons)
    }

    private func makeIcon(icon: SidebarNavigator, scale: Image.Scale = .medium) -> some View {
        Button {
            selection = icon.id
        } label: {
            icon.icon
                .help(icon.description)

            .onDrag {
                draggingItem = icon

                return .init(object: NSString(string: icon.description))
            } preview: {
                RoundedRectangle(cornerRadius: .zero)
                    .frame(width: .zero)
            }
        }
        .buttonStyle(NavigatorToolbarButtonStyle(id: icon, selection: selection, activeState: activeState))
        .imageScale(scale)
    }

    private func getSafeImage(named: String, accesibilityDescription: String?) -> Image {
        if let nsImage = NSImage(systemSymbolName: named, accessibilityDescription: accesibilityDescription) {
            return Image(nsImage: nsImage)
        } else {
            return Image(symbol: named)
        }
    }

    struct NavigatorToolbarButtonStyle: ButtonStyle {
        var id: SidebarNavigator
        var selection: SidebarNavigator
        var activeState: ControlActiveState

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: 12, weight: id == selection ? .semibold : .regular))
                .symbolVariant(id == selection ? .fill : .none)
                .foregroundColor(id == selection ? .accentColor : configuration.isPressed ? .primary : .secondary)
                .frame(width: 25, height: 25, alignment: .center)
                .contentShape(Rectangle())
                .opacity(activeState == .inactive ? 0.45 : 1)
        }
    }

    private struct SidebarDockIcon: Identifiable, Equatable {
        let imageName: String
        let title: String
        var id: Int
        var disabled: Bool = false
    }

    private struct NavigatorSidebarDockIconDelegate: DropDelegate {
        let item: SidebarNavigator
        @Binding var current: SidebarNavigator?
        @Binding var icons: [SidebarNavigator]
        @Binding var hasChangedLocation: Bool
        @Binding var drugItemLocation: CGPoint?

        func dropEntered(info: DropInfo) {
            if current == nil {
                current = item
                drugItemLocation = info.location
            }

            guard item != current, let current = current,
                    let from = icons.firstIndex(of: current),
                    let toIndex = icons.firstIndex(of: item) else { return }

            hasChangedLocation = true
            drugItemLocation = info.location

            if icons[toIndex] != current {
                icons.move(fromOffsets: IndexSet(integer: from), toOffset: toIndex > from ? toIndex + 1 : toIndex)
            }
        }

        func dropExited(info: DropInfo) {
            drugItemLocation = nil
        }

        func dropUpdated(info: DropInfo) -> DropProposal? {
            DropProposal(operation: .move)
        }

        func performDrop(info: DropInfo) -> Bool {
            hasChangedLocation = false
            drugItemLocation = nil
            current = nil
            return true
        }
    }
}
