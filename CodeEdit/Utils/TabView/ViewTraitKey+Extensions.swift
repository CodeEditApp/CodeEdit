//
//  ViewTraitKey+Extensions.swift
//  CodeEdit
//
//  Created by Wouter on 27/12/23.
//

import SwiftUI

struct TabIcon: _ViewTraitKey {
    static var defaultValue: Image?
}

struct TabTitle: _ViewTraitKey {
    static var defaultValue: String?
}

extension View {
    func tabIcon(_ value: Image) -> some View {
        _trait(TabIcon.self, value)
    }

    func tabTitle(_ value: String) -> some View {
        _trait(TabTitle.self, value)
    }
}
