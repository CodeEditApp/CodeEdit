//
//  QuickOpenView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

struct QuickOpenView: View {
    @ObservedObject var workspace: WorkspaceDocument

    var body: some View {
        VStack(spacing: 0.0) {
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .imageScale(.large)
                        .padding(.horizontal)
                    TextField("Open Quickly", text: $workspace.openQuicklyQuery)
                        .font(.system(size: 22, weight: .light, design: .default))
                        .textFieldStyle(.plain)
                }
                    .padding(.vertical)
                    .foregroundColor(.primary.opacity(0.85))
            }
            Divider()
            List(0..<100) { item in
                Text("Item \(item)")
            }
                .removeBackground()
        }
            .frame(minWidth: 500, minHeight: 400, maxHeight: .infinity)
            .background(BlurView(material: .popover, blendingMode: .behindWindow))
            .edgesIgnoringSafeArea(.vertical)
    }
}

struct QuickOpenView_Previews: PreviewProvider {
    static var previews: some View {
        QuickOpenView(workspace: .init())
    }
}
