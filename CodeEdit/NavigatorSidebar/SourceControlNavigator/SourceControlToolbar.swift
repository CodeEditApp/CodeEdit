//
//  SourceControlToolbar.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/05.
//

import SwiftUI
import CodeEditUI

struct SourceControlToolbar<T: View>: View {

    private let height: Double
    private let content: () -> T

    init(
        height: Double = 27,
        @ViewBuilder content: @escaping () -> T
    ) {
        self.height = height
        self.content = content
    }

    var body: some View {
        ZStack {
            HStack {
                content()
                    .padding(.horizontal, 8)
            }
        }
        .frame(height: height)
    }
}
