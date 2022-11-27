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

        @State
        private var url: URL

        init(url: URL) {
            self._url = .init(wrappedValue: url)
            super.init()
        }

        func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}

        func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

        func setTerminalTitle(source: LocalProcessTerminalView, title: String) {}

        func processTerminated(source: TerminalView, exitCode: Int32?) {
            guard let exitCode = exitCode else {
                return
            }
            source.feed(text: "Exit code: \(exitCode)\n\r\n")
            source.feed(text: "To open a new session close and reopen the terminal drawer")
            TerminalEmulatorView.lastTerminal[url.path] = nil
        }
    }
}
