//
//  IgnorePatternModel.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/1/24.
//

import Foundation

class IgnorePatternModel: ObservableObject {
    @Published var patterns: [GlobPattern] = []
    @Published var selection: Set<GlobPattern> = []

    let gitConfig = GitConfigClient(shellClient: currentWorld.shellClient)

    let fileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".gitignore_global")

    init() {
        loadPatterns()
    }

    func loadPatterns() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            patterns = []
            return
        }

        if let content = try? String(contentsOf: fileURL) {
            patterns = content.split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && !$0.starts(with: "#") }
                .map { GlobPattern(value: String($0)) }
        }
    }

    func savePatterns() {
        let content = patterns.map(\.value).joined(separator: "\n")
        try? content.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    @MainActor
    func addPattern() {
        if patterns.isEmpty {
            Task {
                await setupGlobalIgnoreFile()
            }
        }
        patterns.append(GlobPattern(value: ""))
        Task {
            savePatterns()
        }
    }

    @MainActor
    func removePatterns(_ selection: Set<GlobPattern>? = nil) {
        let patternsToRemove = selection ?? self.selection
        patterns.removeAll { patternsToRemove.contains($0) }
        savePatterns()
        self.selection.removeAll()
    }

    func setupGlobalIgnoreFile() async {
        guard !FileManager.default.fileExists(atPath: fileURL.path) else { return }
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        await gitConfig.set(key: "core.excludesfile", value: fileURL.path, global: true)
    }
}
