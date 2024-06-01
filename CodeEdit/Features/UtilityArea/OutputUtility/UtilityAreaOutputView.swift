//
//  UtilityAreaOutputView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI
import LogStream

struct UtilityAreaOutputView: View {
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    @ObservedObject var extensionManager = ExtensionManager.shared

    @State var output: [LogMessage] = []

    @State private var filterText = ""

    @State var selectedOutputSource: ExtensionInfo?

    var filteredOutput: [LogMessage] {
        output.filter { item in
            return filterText == "" ? true : item.message.contains(filterText)
        }
    }

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { _ in
            Group {
                if selectedOutputSource == nil {
                    Text("No output")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .frame(maxHeight: .infinity)
                } else {
                    if let ext = selectedOutputSource {
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(filteredOutput, id: \.self) { item in
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
                            .padding(5)
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
            }
            .paneToolbar {
                Picker("Output Source", selection: $selectedOutputSource) {
                    Text("All Sources")
                        .tag(nil as ExtensionInfo?)
                    ForEach(extensionManager.extensions) {
                        Text($0.name)
                            .tag($0 as ExtensionInfo?)
                    }
                }
                .buttonStyle(.borderless)
                .labelsHidden()
                .controlSize(.small)
                Spacer()
                UtilityAreaFilterTextField(title: "Filter", text: $filterText)
                    .frame(maxWidth: 175)
                Button {
                    output = []
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }
}
