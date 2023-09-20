//
//  View+actionBar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 9/18/23.
//

import SwiftUI

extension View {
    func actionBar<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        self
            .padding(.bottom, 24)
            .overlay(alignment: .bottom) {
                VStack(spacing: -1) {
                    Divider()
                    HStack(spacing: 0) {
                        content()
                            .buttonStyle(.icon(font: Font.system(size: 11, weight: .medium), size: 24))
                    }
                    .frame(height: 16)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 24)
                .background(.separator)
            }
    }
}
