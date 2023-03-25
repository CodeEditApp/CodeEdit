//
//  InspectorSidebarToolbarTop.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/21/22.
//

import SwiftUI

struct InspectorSidebarToolbarTop: View {
    var items: [InspectorTab]

    @Binding
    var selection: InspectorTab

    @State private var targeted: Bool = true
    @State private var icons = [
        InspectorDockIcon(imageName: "doc", title: "File Inspector", id: 0),
        InspectorDockIcon(imageName: "clock", title: "History Inspector", id: 1),
        InspectorDockIcon(imageName: "questionmark.circle", title: "Quick Help Inspector", id: 2)
    ]

    @State private var hasChangedLocation: Bool = false
    @State private var draggingItem: InspectorDockIcon?
    @State private var drugItemLocation: CGPoint?

//    init(selection: Binding<Int>) {
//        self._selection = selection
//    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Divider()
            HStack(spacing: 10) {
                ForEach(items, id: \.self) { icon in
                    makeInspectorIcon(tab: icon)
//                        .opacity(draggingItem?.imageName == icon.imageName &&
//                                 hasChangedLocation &&
//                                 drugItemLocation != nil ? 0.0: 1.0)
//                        .onDrop(
//                            of: [.utf8PlainText],
//                            delegate: InspectorSidebarDockIconDelegate(
//                                item: icon,
//                                current: $draggingItem,
//                                icons: $icons,
//                                hasChangedLocation: $hasChangedLocation,
//                                drugItemLocation: $drugItemLocation
//                            )
//                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .animation(.default, value: items)
            Divider()
        }
        .frame(height: TabBarView.height)
    }

    func makeInspectorIcon(tab: InspectorTab) -> some View {
        Button {
            selection = tab
        } label: {
            Image(systemName: tab.systemImage)
                .help(tab.title)
                .symbolVariant(tab == selection ? .fill : .none)
                .foregroundColor(tab == selection ? .accentColor : .secondary)
                .frame(width: 16, alignment: .center)
//                .onDrag {
//                    if let index = icons.firstIndex(where: { $0.imageName == systemImage }) {
//                        draggingItem = icons[index]
//                    }
//                    return .init(object: NSString(string: systemImage))
//                } preview: {
//                    RoundedRectangle(cornerRadius: .zero)
//                        .frame(width: .zero)
//                }
        }
        .buttonStyle(.plain)
    }

    private func getSafeImage(named: String, accessibilityDescription: String?) -> Image {
        if let nsImage = NSImage(systemSymbolName: named, accessibilityDescription: accessibilityDescription) {
            return Image(nsImage: nsImage)
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
