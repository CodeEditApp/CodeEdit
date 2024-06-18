//
//  TerminalEmulatorView+Coordinator.swift
//  CodeEditModules/TerminalEmulator
//
//  Created by Lukas Pistrol on 24.03.22.
//

import SwiftUI
import SwiftTerm

extension TerminalEmulatorView {
    final class Coordinator: NSObject, LocalProcessTerminalViewDelegate {

        @State private var url: URL

        public var onTitleChange: (_ title: String) -> Void

        init(url: URL, onTitleChange: @escaping (_ title: String) -> Void) {
            self._url = .init(wrappedValue: url)
            self.onTitleChange = onTitleChange
            super.init()
        }

        func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}

        func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

        func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
            onTitleChange(title)
        }

        func processTerminated(source: TerminalView, exitCode: Int32?) {
            guard let exitCode else {
                return
            }
            source.feed(text: "Exit code: \(exitCode)\n\r\n")
            source.feed(text: "To open a new session, create a new terminal tab.")
            TerminalEmulatorView.lastTerminal[url.path] = nil
        }
    }
}
