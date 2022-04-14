//
//  FeedbackToolbar.swift
//  
//
//  Created by Nanashi Li on 2022/04/14.
//

import SwiftUI
import CodeEditUI

struct FeedbackToolbar<T: View>: View {

    private var height: Double
    private var content: () -> T

    init(
        height: Double = 27,
        bgColor: Color = Color(NSColor.controlBackgroundColor),
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
    }
}
