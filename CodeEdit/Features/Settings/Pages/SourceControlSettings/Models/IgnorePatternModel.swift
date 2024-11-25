//
//  IgnorePatternModel.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/1/24.
//

import Foundation

class IgnorePatternModel: ObservableObject {
    @Published var loadingPatterns: Bool = false
    @Published var patterns: [GlobPattern] = [] {
        didSet {
            if !loadingPatterns {
                savePatterns()
            } else {
                loadingPatterns = false
            }
        }
    }
    @Published var selection: Set<UUID> = []

    private let gitConfig = GitConfigClient(shellClient: currentWorld.shellClient)
    private let fileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".gitignore_global")
    private var fileMonitor: DispatchSourceFileSystemObject?

    init() {
        loadPatterns()
        startFileMonitor()
    }

    deinit {
        stopFileMonitor()
    }

    private func startFileMonitor() {
        let fileDescriptor = open(fileURL.path, O_EVTONLY)
        guard fileDescriptor != -1 else {
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: DispatchQueue.main
        )

        source.setEventHandler { [weak self] in
            self?.loadPatterns()
        }

        source.setCancelHandler {
            close(fileDescriptor)
        }

        fileMonitor?.cancel() // Cancel any existing monitor
        fileMonitor = source
        source.resume()
    }

    private func stopFileMonitor() {
        fileMonitor?.cancel()
        fileMonitor = nil
    }

    func loadPatterns() {
        loadingPatterns = true

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

    // Map to track the line numbers of patterns.
    var patternLineMapping: [String: Int] = [:]

    func getPattern(for id: UUID) -> GlobPattern? {
        return patterns.first(where: { $0.id == id })
    }

    func savePatterns() {
        // Suspend the file monitor to avoid self-triggered updates
        stopFileMonitor()

        defer {
            startFileMonitor()
        }

        // Get the file contents; if the file doesn't exist, create it with the patterns
        guard let fileContent = try? String(contentsOf: fileURL) else {
            writeAllPatterns()
            return
        }

        let lines = fileContent.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var patternToLineIndex: [String: Int] = [:] // Map patterns to their line indices
        var reorderedLines: [String] = [] // Store the final reordered lines

        // Map existing patterns in the file
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") {
                patternToLineIndex[trimmedLine] = index
            }
        }

        // Add patterns in the new order specified by the `patterns` array
        for pattern in patterns {
            let value = pattern.value
            if let index = patternToLineIndex[value] {
                // Keep the original line if it matches a pattern
                reorderedLines.append(lines[index])
                patternToLineIndex.removeValue(forKey: value)
            } else {
                // Add new patterns that don't exist in the file
                reorderedLines.append(value)
            }
        }

        // Add remaining non-pattern lines (comments, whitespace)
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                reorderedLines.insert(line, at: index)
            }
        }

        // Ensure single blank line at the end
        reorderedLines = cleanUpWhitespace(in: reorderedLines)

        // Write the updated content back to the file
        let updatedContent = reorderedLines.joined(separator: "\n")
        try? updatedContent.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    private func writeAllPatterns() {
        let content = patterns.map(\.value).joined(separator: "\n")
        try? content.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    private func handlePatterns(
        _ lines: inout [String],
        existingPatterns: inout Set<String>,
        patternLineMap: inout [String: Int]
    ) {
        var handledPatterns = Set<String>()

        // Update or preserve existing patterns
        for pattern in patterns {
            let value = pattern.value
            if let lineIndex = patternLineMap[value] {
                // Pattern already exists, update it in place
                lines[lineIndex] = value
                handledPatterns.insert(value)
            } else {
                // Check if the pattern has been edited and corresponds to a previous pattern
                if let oldPattern = existingPatterns.first(where: { !handledPatterns.contains($0) && $0 != value }),
                   let lineIndex = patternLineMap[oldPattern] {
                    lines[lineIndex] = value
                    existingPatterns.remove(oldPattern)
                    patternLineMap[value] = lineIndex
                    handledPatterns.insert(value)
                } else {
                    // Append new patterns at the end
                    if let lastLine = lines.last, lastLine.trimmingCharacters(in: .whitespaces).isEmpty {
                        lines.removeLast() // Remove trailing blank line before appending
                    }
                    lines.append(value)
                }
            }
        }

        // Remove patterns no longer in the list
        let currentPatterns = Set(patterns.map(\.value))
        lines = lines.filter { line in
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            return trimmedLine.isEmpty || trimmedLine.hasPrefix("#") || currentPatterns.contains(trimmedLine)
        }
    }

    private func cleanUpWhitespace(in lines: [String]) -> [String] {
        var cleanedLines: [String] = []
        var previousLineWasBlank = false

        for line in lines {
            let isBlank = line.trimmingCharacters(in: .whitespaces).isEmpty
            if !(isBlank && previousLineWasBlank) {
                cleanedLines.append(line)
            }
            previousLineWasBlank = isBlank
        }

        // Trim extra blank lines at the end, ensuring only a single blank line
        while let lastLine = cleanedLines.last, lastLine.trimmingCharacters(in: .whitespaces).isEmpty {
            cleanedLines.removeLast()
        }
        cleanedLines.append("") // Ensure exactly one blank line at the end

        // Trim whitespace at the top of the file
        while let firstLine = cleanedLines.first, firstLine.trimmingCharacters(in: .whitespaces).isEmpty {
            cleanedLines.removeFirst()
        }

        return cleanedLines
    }

    @MainActor
    func addPattern() {
        if patterns.isEmpty {
            Task {
                await setupGlobalIgnoreFile()
            }
        }
        patterns.append(GlobPattern(value: ""))
    }

    @MainActor
    func removePatterns(_ selection: Set<UUID>? = nil) {
        let patternsToRemove = selection?.compactMap { getPattern(for: $0) } ?? []
        patterns.removeAll { patternsToRemove.contains($0) }
        self.selection.removeAll()
    }

    func setupGlobalIgnoreFile() async {
        guard !FileManager.default.fileExists(atPath: fileURL.path) else { return }
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        await gitConfig.set(key: "core.excludesfile", value: fileURL.path, global: true)
    }
}
