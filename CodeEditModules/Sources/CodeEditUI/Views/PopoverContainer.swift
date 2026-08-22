//
//  PopoverContainer.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/29/25.
//

import SwiftUI

/// Container for SwiftUI views presented in a popover.
/// On tahoe and above, adds the correct container shape.
public struct PopoverContainer<ContentView: View>: View {
    let content: () -> ContentView

    public init(@ViewBuilder content: @escaping () -> ContentView) {
        self.content = content
    }

    public var body: some View {
        let base = VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .font(.subheadline)

        return Group {
            if #available(macOS 26, *) {
                base
                    .padding(13)
                    .containerShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                base.padding(5)
            }
        }
        .frame(minWidth: 215)
    }
}
