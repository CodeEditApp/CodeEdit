//
//  InspectorSidebarTabBar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/21/22.
//

import SwiftUI

struct InspectorSidebarTabBar: View {
    @Environment(\.controlActiveState) private var activeState

    var items: [InspectorTab]

    @Binding
    var selection: InspectorTab.ID

    var position: SettingsData.SidebarTabBarPosition

    @State private var hasChangedLocation: Bool = false
    @State private var draggingItem: InspectorDockIcon?
    @State private var drugItemLocation: CGPoint?

    var body: some View {
        if position == .top {
            topBody
        } else {
            sideBody
        }
    }

    var topBody: some View {
        GeometryReader { proxy in
            iconsView(size: proxy.size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .top) {
                    Divider()
                }
                .overlay(alignment: .bottom) {
                    Divider()
                }
                .animation(.default, value: items)
        }
        .frame(maxWidth: .infinity, idealHeight: 29)
        .fixedSize(horizontal: false, vertical: true)
    }

    var sideBody: some View {
        GeometryReader { proxy in
            iconsView(size: proxy.size)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .leading) {
                    HStack {
                        Divider()
                    }
                }
                .animation(.default, value: items)
        }
        .frame(idealWidth: 40, maxHeight: .infinity)
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    func iconsView(size: CGSize) -> some View {
        let layout = position == .top
            ? AnyLayout(HStackLayout(spacing: 0))
            : AnyLayout(VStackLayout(spacing: 0))
        layout {
            ForEach(items) { icon in
                makeIcon(tab: icon, size: size)
                    .opacity(draggingItem?.imageName == icon.systemImage &&
                             hasChangedLocation &&
                             drugItemLocation != nil ? 0.0 : 1.0)
//                    .onDrop(
//                        of: [.utf8PlainText],
//                        delegate: InspectorSidebarDockIconDelegate(
//                            item: icon,
//                            current: $draggingItem,
//                            icons: $icons,
//                            hasChangedLocation: $hasChangedLocation,
//                            drugItemLocation: $drugItemLocation
//                        )
//                    )
            }
            if position == .side {
                Spacer()
            }
        }
    }

    private func makeIcon(
        tab: InspectorTab,
        scale: Image.Scale = .medium,
        size: CGSize
    ) -> some View {
        Button {
            selection = tab.id
        } label: {
            getSafeImage(named: tab.systemImage, accessibilityDescription: tab.title)
                .font(.system(size: 12.5))
                .symbolVariant(tab.id == selection ? .fill : .none)
                .frame(
                    width: position == .side ? 40 : 24,
                    height: position == .side ? 28 : size.height,
                    alignment: .center
                )
                .help(tab.title)
//                .onDrag {
//                    if let index = icons.firstIndex(where: { $0.imageName == named }) {
//                        draggingItem = icons[index]
//                    }
//                    return .init(object: NSString(string: named))
//                } preview: {
//                    RoundedRectangle(cornerRadius: .zero)
//                        .frame(width: .zero)
//                }
        }
        .buttonStyle(.icon(isActive: tab.id == selection, size: nil))
    }

    private func getSafeImage(named: String, accessibilityDescription: String?) -> Image {
        // We still use the NSImage init to check if a symbol with the name exists.
        if NSImage(systemSymbolName: named, accessibilityDescription: nil) != nil {
            return Image(systemName: named)
        } else {
            return Image(symbol: named)
        }
    }

    private struct InspectorDockIcon: Identifiable, Equatable {
        let imageName: String
        let title: String
        var id: Int
    }

    private struct InspectorSidebarDockIconDelegate: DropDelegate {
        let item: InspectorDockIcon
        @Binding var current: InspectorDockIcon?
        @Binding var icons: [InspectorDockIcon]
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
