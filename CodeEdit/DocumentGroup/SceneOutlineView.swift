//
//  SceneOutlineView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 07/01/2023.
//

import SwiftUI

struct SceneOutlineView: View {
    var item: FileTree
    @State var isExpanded = false

    var body: some View {
        //        VStack(alignment: .leading) {
        Text(item.wrapper.filename ?? "")
            .onTapGesture {
                isExpanded.toggle()
            }
            .tag(item)

            .buttonStyle(.plain)

        Group {
            if isExpanded, let children = item.children {
                Section {
                    ForEach(children) {
                        SceneOutlineView(item: $0)
                    }
                }
                .padding(.leading, 10)
                .transition(.slide)
                .animation(.linear)
            }
        }
        .transition(.slide)
        .animation(.linear)
        //        }
        //        .frame(maxWidth: .infinity)
    }
}
