//
//  Live.swift
//  CodeEditModules/ShellClient
//
//  Created by Marco Carnevali on 27/03/22.
//
import Foundation

public extension ShellClient {
    static let live = ShellClient { command in
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        try task.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
