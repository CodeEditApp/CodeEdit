//
//  DropDelegate.swift
//  CodeEdit
//
//  Created by Wouter on 27/12/23.
//

import SwiftUI

extension TabViewTabBar {
    struct Delegate: DropDelegate {
        let tabwidths: [CGFloat?]
        let onInsert: OnInsertConfiguration?

        @Binding var tempIndex: Int?

        func dropExited(info: DropInfo) {
            withAnimation(.spring) {
                tempIndex = nil
            }
        }

        func dropUpdated(info: DropInfo) -> DropProposal? {
            var width = info.location.x
            var index = 0
            while index < tabwidths.count && width > (tabwidths[index]!/2) {
                width -= tabwidths[index]!
                index += 1
            }
            withAnimation(.spring) {
                tempIndex = index
            }
            return .some(.init(operation: .copy))
        }

        func performDrop(info: DropInfo) -> Bool {
            var width = info.location.x
            var index = 0
            while index < tabwidths.count && width > (tabwidths[index]!/2) {
                width -= tabwidths[index]!
                index += 1
            }

            if let onInsert {
                onInsert.action(index, info.itemProviders(for: onInsert.supportedContentTypes))
                return true
            }
            return false
        }

        func validateDrop(info: DropInfo) -> Bool {
            guard let onInsert else { return false }
            return info.hasItemsConforming(to: onInsert.supportedContentTypes)
        }
    }
}
