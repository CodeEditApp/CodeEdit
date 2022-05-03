//
//  WelcomeWindowView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import ShellClient

public struct WelcomeWindowView: View {

    private let openDocument: (URL?, @escaping () -> Void) -> Void
    private let newDocument: () -> Void
    private let dismissWindow: () -> Void
    private let shellClient: ShellClient

    public init(
        shellClient: ShellClient,
        openDocument: @escaping (URL?, @escaping () -> Void) -> Void,
        newDocument: @escaping () -> Void,
        dismissWindow: @escaping () -> Void
    ) {
        self.shellClient = shellClient
        self.openDocument = openDocument
        self.newDocument = newDocument
        self.dismissWindow = dismissWindow
    }

    public var body: some View {
        HStack(spacing: 0) {
            WelcomeView(
                shellClient: shellClient,
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
