//
//  AnyVariadicView+Extensions.swift
//  CodeEdit
//
//  Created by Wouter on 27/12/23.
//

import Engine
import UniformTypeIdentifiers

extension AnyVariadicView.Subview {
    var onMove: ((IndexSet, Int) -> Void)? {
        self["s7SwiftUI14OnMoveTraitKeyV", as: ((IndexSet, Int) -> Void).self]
    }

    var onDelete: ((IndexSet) -> Void)? {
        self["s7SwiftUI16OnDeleteTraitKeyV", as: ((IndexSet) -> Void).self]
    }

    var onInsert: OnInsertConfiguration? {
        let item = self["s7SwiftUI16OnInsertTraitKeyV", as: Any.self]

        return unsafePartialBitCast(item, to: OnInsertConfiguration?.self)
    }

    var contentOffset: Int? {
        self["s7SwiftUI32DynamicViewContentOffsetTraitKeyV", as: Int.self]
    }

    var dynamicViewContentID: Int? {
        self["s7SwiftUI28DynamicViewContentIDTraitKeyV", as: Int.self]
    }
}

struct OnInsertConfiguration {
    var supportedContentTypes: [UTType] = []
    var action: (Int, [NSItemProvider]) -> Void
}
