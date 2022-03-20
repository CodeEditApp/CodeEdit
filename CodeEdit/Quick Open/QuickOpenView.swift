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
        VStack {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "doc.text.magnifyingglass")
                    .imageScale(.large)
                    .padding(.horizontal)
                TextField("Open Quickly", text: $workspace.openQuicklyQuery)
                    .font(.system(size: 22, weight: .light, design: .default))
                    .textFieldStyle(.plain)
            }
                .foregroundColor(.primary.opacity(0.8))
        }
            .frame(maxHeight: .infinity)
            .background(BlurView(material: .hudWindow, blendingMode: .behindWindow))
            .edgesIgnoringSafeArea(.vertical)
    }
}

struct QuickOpenView_Previews: PreviewProvider {
    static var previews: some View {
        QuickOpenView(workspace: .init())
    }
}
