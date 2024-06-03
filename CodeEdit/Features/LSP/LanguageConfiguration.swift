//
//  LanguageConfiguration.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

func loadLSPConfigurations(from configFile: URL?) -> [LanguageIdentifier: LanguageServerBinary] {
    // TEMP: This is in a variable to avoid lint error
    let rustPath = "/Users/abe/.vscode/extensions/rust-lang.rust-analyzer-0.3.1823-darwin-arm64/server/rust-analyzer"
    // TODO: LOAD FROM FILE
    return [
        .python: LanguageServerBinary(
            execPath: "/opt/homebrew/Cellar/python-lsp-server/1.10.0/libexec/bin/pylsp",
            args: [
                "--log-file",
                "/Users/abe/Documents/Swift/CodeEditLSPExample/CodeEditLSPExample/LSP_Logs/python.log"
            ],
            env: ProcessInfo.processInfo.environment
        ),
        .rust: LanguageServerBinary(
            execPath: rustPath,
            args: [
                "--verbose",
                "--log-file",
                "/Users/abe/Documents/Swift/CodeEditLSPExample/CodeEditLSPExample/LSP_Logs/rust.log"
            ],
            env: ProcessInfo.processInfo.environment // ["RUST_BACKTRACE": "full"]
        )
    ]
}
