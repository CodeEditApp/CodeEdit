//
//  PopoverContainer.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/29/25.
//

import SwiftUI

/// Container for SwiftUI views presented in a popover.
/// On tahoe and above, adds the correct container shape.
struct PopoverContainer<ContentView: View>: View {
    let content: () -> ContentView

    init(@ViewBuilder content: @escaping () -> ContentView) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .font(.subheadline)
        .if(.tahoe) {
            $0.padding(13).containerShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        } else: {
            $0.padding(5)
        }
        .frame(minWidth: 215)
    }
}
