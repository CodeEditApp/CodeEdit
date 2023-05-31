//
//  DebugAreaDebugView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI

struct DebugAreaOutputView: View {
    @EnvironmentObject
    private var model: DebugAreaViewModel

    @State
    private var searchText = ""

    @State
    private var selectedOutputSourceId = "ALL_SOURCES"

    var body: some View {
        DebugAreaTabView { _ in
            Text("No output")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .paneToolbar {
                    Picker("Output Source", selection: $selectedOutputSourceId) {
                        Text("All Sources")
                            .tag("ALL_SOURCES")
//                        ForEach(outputSources, id: \.self.id) { source in
//                            Text(source.title)
//                                .tag(source.id)
//                        }
                    }
                    .buttonStyle(.borderless)
                    .labelsHidden()
                    .controlSize(.small)
                    Spacer()
                    FilterTextField(title: "Filter", text: $searchText)
                        .frame(maxWidth: 175)
                        .padding(.leading, -2)
                    Button {
                        // clear logs
                    } label: {
                        Image(systemName: "trash")
                    }
                }
        }
    }
}
