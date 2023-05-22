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

    var ext: ExtensionInfo

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
        .task(id: ext.pid) {
            output = []
            for await item in LogStream.logs(for: ext.pid, flags: [.info, .historical, .processOnly]) {
                output.append(item)
            }
        }
    }
}
