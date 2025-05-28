//
//  HistoryPopoverView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/04/18.
//

import SwiftUI

struct HistoryPopoverView: View {

    private var commit: GitCommit

    init(commit: GitCommit) {
        self.commit = commit
    }

    var body: some View {
        VStack {
            CommitDetailsHeaderView(commit: commit)

            Divider()

            VStack(alignment: .leading, spacing: 0) {
                // TODO: Implementation Needed
                ActionButton("Show Commit", systemImage: "clock") {}
                    .disabled(true)
                // TODO: Implementation Needed
                ActionButton("Open in Code Review", systemImage: "arrow.left.arrow.right") {}
                    .disabled(true)
                ActionButton("Email \(commit.author)", systemImage: "envelope") {
                    let service = NSSharingService(named: NSSharingService.Name.composeEmail)
                    service?.recipients = [commit.authorEmail]
                    service?.perform(withItems: [])
                }
            }
            .padding(.horizontal, 6)
        }
        .padding(.top)
        .padding(.bottom, 5)
        .frame(width: 310)
    }

    private struct ActionButton: View {

        private var title: String
        private var image: String
        private var action: () -> Void

        @State private var isHovering: Bool = false

        @Environment(\.isEnabled)
        private var isEnabled

        init(_ title: String, systemImage: String, action: @escaping () -> Void) {
            self.title = title
            self.image = systemImage
            self.action = action
        }

        var body: some View {
            Button {
                action()
            } label: {
                Label(title: {
                    Text(title)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }, icon: {
                    Image(systemName: image)
                        .frame(width: 16, alignment: .center)
                        .padding(.leading, -2.5)
                        .padding(.trailing, 2.5)
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(isHovering && isEnabled ? .white : .primary)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(
                EffectView.selectionBackground(isHovering && isEnabled)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .onHover { hovering in
                isHovering = hovering
            }
        }
    }
}
