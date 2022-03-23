//
//  Interface.swift
//  CodeFile
//
//  Created by Marco Carnevali on 21/03/22.
//

import Foundation

public extension GitClient {
    static func `default`(directoryURL: URL) -> GitClient {
        func shell(_ command: String) -> String {
            let command = "cd \(directoryURL.relativePath);\(command)"
            let task = Process()
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            task.arguments = ["-c", command]
            task.executableURL = URL(fileURLWithPath: "/bin/zsh")
            try? task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        }

        func getBranches() -> [String] {
            shell("git branch --format \"%(refname:short)\"")
                .components(separatedBy: "\n")
                .filter { $0 != "" }
        }

        func getCurrentBranchName() -> String {
            shell("git rev-parse --abbrev-ref HEAD")
                .replacingOccurrences(of: "\n", with: "")
        }

        func checkoutBranch(name: String) throws {
            guard getCurrentBranchName() != name else { return }
            let output = shell("git checkout \(name)")
            if !output.contains("Switched to branch") {
                throw GitClientError.outputError(output)
            }
        }
        func cloneRepository(url: String) throws {
            let output = shell("git clone \(url)")
            if output.contains("fatal") {
                throw GitClientError.outputError(output)
            }
        }

        return GitClient(
            getCurrentBranchName: getCurrentBranchName,
            getBranches: getBranches,
            checkoutBranch: checkoutBranch(name:),
            pull: { _ = shell("git pull") },
            cloneRepository: cloneRepository(url:)
        )
    }
}
