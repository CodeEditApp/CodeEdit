//
//  StatusBarPullButton.swift
//
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

internal struct StatusBarPullButton: View {
    @ObservedObject
    private var model: StatusBarModel

    internal init(model: StatusBarModel) {
        self.model = model
    }

    internal var body: some View {
        Button {
            model.isReloading = true
            try? model.gitClient.pull()
            // Just for looks for now. In future we'll call a function like
            // `reloadFileStatus()` here which will set/unset `reloading`
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.model.isReloading = false
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .imageScale(.medium)
                .rotationEffect(.degrees(model.isReloading ? 360 : 0))
                .animation(animation, value: model.isReloading)
                .opacity(model.isReloading ? 1 : 0)
                // A bit of a hacky solution to prevent spinning counterclockwise once `reloading` changes to `false`
                .overlay {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .imageScale(.medium)
                        .opacity(model.isReloading ? 0 : 1)
                }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .onHover { isHovering($0) }
        .disabled(model.selectedBranch == nil)
    }

    // Temporary
    private var animation: Animation {
        // 10x speed when not reloading to make invisible ccw spin go fast in case button is pressed multiple times.
        .linear.speed(model.isReloading ? 0.5 : 10)
    }
}
