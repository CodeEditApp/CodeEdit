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

    var body: some View {
        Picker("", selection: $selection) {
//            ForEach(colors, id: \.hex) { color in
//                HStack {
//
//
//                    Text("Blue")
//                }
//            }

            Rectangle()
                .foregroundColor(.green)
                .frame(width: 23, height: 11)
                .padding()
        }
        .fixedSize()
    }
}
