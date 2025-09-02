//
//  SourceControlToolbarBottom.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct FindNavigatorToolbarBottom: View {
    @State private var text = ""

    var body: some View {
        NavigatorFilterView(
            text: $text,
            menu: { EmptyView() },
            leadingAccessories: {
                Image(
                    systemName: text.isEmpty
                    ? "line.3.horizontal.decrease.circle"
                    : "line.3.horizontal.decrease.circle.fill"
                )
                .foregroundStyle(
                    text.isEmpty
                    ? Color(nsColor: .secondaryLabelColor)
                    : Color(nsColor: .controlAccentColor)
                )
                .padding(.leading, 4)
                .help("Show results with matching text")
            },
            trailingAccessories: { EmptyView() }
        )
    }
}
