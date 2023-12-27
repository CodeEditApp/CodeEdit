//
//  IconView.swift
//  CodeEdit
//
//  Created by Wouter on 27/12/23.
//

import SwiftUI

extension TabViewTabBar {
    struct IconView: View {
        let tab: Tab
        let size: CGSize
        @Binding var selection: TabID
        let isVertical: Bool
        var body: some View {
            Button {
                if let tag = tab.tag {
                    selection = tag
                }
            } label: {
                let label = tab.image
                    .accessibilityLabel(tab.title ?? "")
                    .font(.system(size: 12.5))
                    .symbolVariant(tab.tag == selection ? .fill : .none)
                    .frame(
                        width: isVertical ? 40 : 24,
                        height: isVertical ? 28 : size.height,
                        alignment: .center
                    )
                    .help(tab.title ?? "")

                if let onDelete = tab.onDelete {
                    label
                        .draggable { () -> String in
                            if let offset = tab.dynamicViewContentOffset {
                                withAnimation(.spring) {
                                    onDelete(IndexSet(integer: offset))
                                }
                            }
                            return tab.title ?? ""
                        }
                } else {
                    label
                }
            }
            .buttonStyle(.icon(isActive: tab.tag == selection, size: CGFloat?.none))
        }
    }
}
