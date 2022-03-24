//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 24.03.22.
//

import SwiftUI
import SwiftTerm

public extension TerminalEmulatorView {
	class Coordinator: NSObject, LocalProcessTerminalViewDelegate {

		public override init() {}

		public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}

		public func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

		public func setTerminalTitle(source: LocalProcessTerminalView, title: String) {}

		public func processTerminated(source: TerminalView, exitCode: Int32?) {
			guard let exitCode = exitCode else {
				return
			}
			source.feed(text: "Exit code: \(exitCode)\n\r\n")
			source.feed(text: "To restart please close and reopen this file")
		}
	}
}
