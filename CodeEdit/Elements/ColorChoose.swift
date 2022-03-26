//
//  ColorChoose.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/26.
//

import SwiftUI

struct ColorChoose<T: Hashable>: View {
    @Binding var selected: T
    let selection: T
    let colors: [Color]
    let onTap: (() -> Void)

    var body: some View {
        Circle()
            .fill(AngularGradient(colors: colors, center: .center))
            .frame(width: 15, height: 15)
            .overlay {
                Circle()
                    .stroke(lineWidth: 2)
                    .fill(.gray)
                    .opacity(0.3)
            }
            .overlay {
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(.white)
                    .opacity(selected == selection ? 1 : 0)
            }
            .onTapGesture {
                selected = selection
                onTap()
            }
    }

    init(selected: Binding<T>, selection: T, colors: [Color], onTap: (() -> Void)? = nil) {
        self._selected = selected
        self.selection = selection
        self.colors = colors
        self.onTap = onTap ?? {}
    }
}
