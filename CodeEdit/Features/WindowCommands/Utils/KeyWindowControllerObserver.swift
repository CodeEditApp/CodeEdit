//
//  KeyWindowControllerObserver.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/2/24.
//

import SwiftUI

struct KeyWindowControllerObserver: ViewModifier {
    @Binding var windowController: CodeEditWindowController?

    func body(content: Content) -> some View {
        content.onReceive(NSApp.publisher(for: \.keyWindow)) { window in
            windowController = window?.windowController as? CodeEditWindowController
        }
    }
}

extension View {
    @ViewBuilder
    func observeWindowController(_ binding: Binding<CodeEditWindowController?>) -> some View {
        self.modifier(KeyWindowControllerObserver(windowController: binding))
    }
}
