//
//  FeedbackToolbar.swift
//  CodeEditModules/Feedback
//
//  Created by Nanashi Li on 2022/04/14.
//

import SwiftUI

struct FeedbackToolbar<T: View>: View {

    private var content: () -> T

    init(
        bgColor: Color = Color(NSColor.controlBackgroundColor),
        @ViewBuilder content: @escaping () -> T
    ) {
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
