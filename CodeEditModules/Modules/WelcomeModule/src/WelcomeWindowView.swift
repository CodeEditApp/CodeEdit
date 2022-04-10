//
//  WelcomeWindowView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI

public struct WelcomeWindowView: View {

    private let openDocument: (URL?, @escaping () -> Void) -> Void
    private let newDocument: () -> Void
    private let dismissWindow: () -> Void

    public init(
        openDocument: @escaping (URL?, @escaping () -> Void) -> Void,
        newDocument: @escaping () -> Void,
        dismissWindow: @escaping () -> Void
    ) {
        self.openDocument = openDocument
        self.newDocument = newDocument
        self.dismissWindow = dismissWindow
    }

    public var body: some View {
        HStack(spacing: 0) {
            WelcomeView(
                openDocument: openDocument,
                newDocument: newDocument,
                dismissWindow: dismissWindow
            )
            RecentProjectsView(
                openDocument: openDocument,
                dismissWindow: dismissWindow
            )
        }
        .edgesIgnoringSafeArea(.top)
    }
}
