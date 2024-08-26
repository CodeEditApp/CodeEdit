//
//  TerminalEmulatorView+Coordinator.swift
//  CodeEditModules/TerminalEmulator
//
//  Created by Lukas Pistrol on 24.03.22.
//

import SwiftUI
import SwiftTerm

extension TerminalEmulatorView {
    final class Coordinator: NSObject, CELocalProcessTerminalViewDelegate {
        private let terminalID: UUID
        public var onTitleChange: (_ title: String) -> Void

        init(terminalID: UUID, onTitleChange: @escaping (_ title: String) -> Void) {
            self.terminalID = terminalID
            self.onTitleChange = onTitleChange
            super.init()
        }

        func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}

        func sizeChanged(source: CETerminalView, newCols: Int, newRows: Int) {}

        func setTerminalTitle(source: CETerminalView, title: String) {
            onTitleChange(title)
        }

        func processTerminated(source: TerminalView, exitCode: Int32?) {
            guard let exitCode else {
                return
            }
            source.feed(text: "Exit code: \(exitCode)\n\r\n")
            source.feed(text: "To open a new session, create a new terminal tab.")
            TerminalCache.shared.removeCachedView(terminalID)
        }
    }
}
