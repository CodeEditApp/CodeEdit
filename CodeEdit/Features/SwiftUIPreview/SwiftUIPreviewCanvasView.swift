//
//  SwiftUIPreviewCanvasView.swift
//  CodeEdit
//
//  Created by Aryan Rogye on 5/4/26.
//

import SwiftUI

struct SwiftUIPreviewCanvasView: View {
    @ObservedObject var runner: SwiftUIPreviewRunner

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label("Preview", systemImage: "play.rectangle")
                    .font(.headline)

                Spacer()

                if runner.isCompiling {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 34)
            .background(EffectView(.headerView))

            Divider()

            SwiftUIPreviewHostView(previewView: runner.previewView)
                .overlay {
                    if runner.previewView == nil {
                        CEContentUnavailableView(
                            runner.isCompiling ? "Compiling Preview" : "No Preview Loaded"
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !runner.logs.isEmpty {
                Divider()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(runner.logs.enumerated()), id: \.offset) { _, log in
                            Text(log)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(8)
                }
                .frame(minHeight: 96, idealHeight: 140, maxHeight: 180)
            }
        }
        .frame(minWidth: 360)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
