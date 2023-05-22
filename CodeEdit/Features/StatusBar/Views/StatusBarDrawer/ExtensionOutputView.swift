//
//  ExtensionOutputView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 22/05/2023.
//

import SwiftUI
import LogStream

struct ExtensionOutputView: View {
    @ObservedObject var extensionManager = ExtensionManager.shared

    @State var output: [LogMessage] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(output, id: \.self) { item in
                    HStack {
                        Text(item.message)
                            .fontWeight(.semibold)
                            .fontDesign(.monospaced)
                            .foregroundColor(item.type.color)
                        Spacer()
                    }
                    .padding(.leading, 2)
                }
            }
            .frame(maxWidth: .infinity)
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
        }
        .rotationEffect(.radians(.pi))
        .scaleEffect(x: -1, y: 1, anchor: .center)
        .task(id: extensionManager.extensions.map(\.pid)) {
            for await item in LogStream.logs(for: extensionManager.extensions.map(\.pid), flags: [.info, .historical, .processOnly]) {
                output.append(item)
            }
        }
    }
}
