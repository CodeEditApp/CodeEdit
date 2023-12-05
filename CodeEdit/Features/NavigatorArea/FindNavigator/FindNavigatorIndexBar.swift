//
//  FindNavigatorIndexBar.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/4/23.
//

import SwiftUI

struct FindNavigatorIndexBar: View {
    @ObservedObject private var state: WorkspaceDocument.SearchState
    @State private var progress: Double = 0.0
    @State private var shouldShow: Bool = false

    init(state: WorkspaceDocument.SearchState) {
        self.state = state
    }

    var body: some View {
        Group {
            if shouldShow {
                HStack(alignment: .center) {
                    ProgressView(value: progress, total: 1.0) {
                        EmptyView()
                    } currentValueLabel: {
                        HStack {
                            Text("Indexing \(Int(progress * 100))%")
                                .font(.system(size: 10))
                                .animation(.none)
                        }
                    }
                    // swiftlint:disable:next line_length
                    .help("Indexing current workspace files for search. Searches performed while indexing may return incomplete results.")
                }
                .transition(.asymmetric(insertion: .identity, removal: .move(edge: .top).combined(with: .opacity)))
            }
        }
        .onAppear {
            updateWithNewStatus(state.indexStatus)
        }
        .onReceive(state.$indexStatus) { newStatus in
            updateWithNewStatus(newStatus)
        }
    }

    /// Updates the bar with a new status update.
    /// - Parameter status: The new status.
    private func updateWithNewStatus(_ status: WorkspaceDocument.SearchState.IndexStatus) {
            switch status {
            case .none:
                self.progress = 0.0
                shouldShow = false
            case .indexing(let progress):
                if shouldShow {
                    withAnimation {
                        self.progress = progress
                    }
                } else {
                    shouldShow = true
                    self.progress = progress
                }
            case .done:
                self.progress = 1.0
                withAnimation(.default.delay(0.75)) {
                    shouldShow = false
                }
            }
    }
}
