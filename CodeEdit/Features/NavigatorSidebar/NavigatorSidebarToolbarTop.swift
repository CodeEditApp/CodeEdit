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
    private var selection: Int

    @State private var icons = [
        SidebarDockIcon(imageName: "folder", title: "Project", id: 0),
        SidebarDockIcon(imageName: "vault", title: "Version Control", id: 1),
        SidebarDockIcon(imageName: "magnifyingglass", title: "Search", id: 2),
        SidebarDockIcon(imageName: "shippingbox", title: "...", id: 3, disabled: true),
        SidebarDockIcon(imageName: "play", title: "...", id: 4, disabled: true),
        SidebarDockIcon(imageName: "exclamationmark.triangle", title: "...", id: 5, disabled: true),
        SidebarDockIcon(imageName: "curlybraces.square", title: "...", id: 6, disabled: true),
        SidebarDockIcon(imageName: "puzzlepiece.extension", title: "...", id: 7, disabled: true),
        SidebarDockIcon(imageName: "square.grid.2x2", title: "...", id: 8, disabled: true)
    ]
    @State private var hasChangedLocation: Bool = false
    @State private var draggingItem: SidebarDockIcon?
    @State private var drugItemLocation: CGPoint?

    init(selection: Binding<Int>) {
        self._selection = selection
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(icons) { icon in
                makeIcon(named: icon.imageName, title: icon.title, id: icon.id)
                    .opacity(draggingItem?.imageName == icon.imageName &&
                             hasChangedLocation &&
                             drugItemLocation != nil ? 0.0: icon.disabled ? 0.3 : 1.0)
                    .onDrop(of: [.utf8PlainText],
                            delegate: NavigatorSidebarDockIconDelegate(item: icon,
                                                                        current: $draggingItem,
                                                                        icons: $icons,
                                                                        hasChangedLocation: $hasChangedLocation,
                                                                        drugItemLocation: $drugItemLocation))
                    .disabled(icon.disabled)
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

    private func makeIcon(named: String, title: String, id: Int, scale: Image.Scale = .medium) -> some View {
        Button {
            selection = id
        } label: {
            getSafeImage(named: named, accesibilityDescription: title)
            .help(title)
            .onDrag {
            if let index = icons.firstIndex(where: { $0.imageName == named }) {
                draggingItem = icons[index]
            }
                return .init(object: NSString(string: named))
            } preview: {
                RoundedRectangle(cornerRadius: .zero)
                    .frame(width: .zero)
            }
        }
        .buttonStyle(NavigatorToolbarButtonStyle(id: id, selection: selection, activeState: activeState))
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
        var id: Int
        var selection: Int
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
        let item: SidebarDockIcon
        @Binding var current: SidebarDockIcon?
        @Binding var icons: [SidebarDockIcon]
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

struct NavigatorSidebarToolbar_Previews: PreviewProvider {
    static var previews: some View {
        NavigatorSidebarToolbarTop(selection: .constant(0))
    }
}
