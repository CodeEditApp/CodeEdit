//
//  CEColorPicker.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/26.
//

import SwiftUI

struct CEColorPicker<T: Hashable>: View {
    @Binding var selection: T

    let colors: [Color]
    let name: String

    var body: some View {
        Picker("", selection: $selection) {
            HStack {
                Image(nsImage: .init(named: .init("ColorPickerDefault"))?.tint(color: .green) ?? NSImage())

                Text(name)
            }
            .padding(.trailing)
        }
        .fixedSize()
    }
}
