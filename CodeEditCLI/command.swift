//
//  main.swift
//  CodeEditCLI
//
//  Created by Ziyuan Zhao on 2022/3/17.
//

import ArgumentParser
import Foundation
import Commands

@main
struct CodeEditCLI: ParsableCommand {
    @Argument(help: "The file or directory you want to open with CodeEdit")
    var path: String?
    
    mutating func run() throws {
        if let path = path {
            var toOpenPathURL = URL(fileURLWithPath: "")
            // TODO: a better way to check the path is absolute
            if (path.starts(with: "/")) {
                toOpenPathURL = URL(fileURLWithPath: path)
            } else {
                let currentPathURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                toOpenPathURL = currentPathURL.appendingPathComponent(path).standardizedFileURL
            }
            Commands.Bash.run("open -a CodeEdit --args --path \(toOpenPathURL.path)")
        } else {
            Commands.Bash.run("open -a CodeEdit")
        }
    }
}

