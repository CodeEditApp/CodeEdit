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
    private var fileMonitor: DispatchSourceFileSystemObject?

    init() {
        Task {
            try? await startFileMonitor()
            await loadPatterns()
        }
    }

    deinit {
        stopFileMonitor()
    }

    private func gitIgnoreURL() async throws -> URL {
        let excludesfile = try await gitConfig.get(key: "core.excludesfile") ?? ""
        if !excludesfile.isEmpty {
            if excludesfile.starts(with: "~/") {
                let relativePath = String(excludesfile.dropFirst(2)) // Remove "~/"
                return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(relativePath)
            } else if excludesfile.starts(with: "/") {
                return URL(fileURLWithPath: excludesfile) // Absolute path
            } else {
                return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(excludesfile)
            }
        } else {
            let defaultPath = ".gitignore_global"
            let fileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(defaultPath)
            await gitConfig.set(key: "core.excludesfile", value: "~/\(defaultPath)", global: true)
            return fileURL
        }
    }

    private func startFileMonitor() async throws {
        let fileURL = try await gitIgnoreURL()
        let fileDescriptor = open(fileURL.path, O_EVTONLY)
        guard fileDescriptor != -1 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: DispatchQueue.main
        )

        source.setEventHandler {
            Task {
                await self.loadPatterns()
            }
        }

        source.setCancelHandler {
            close(fileDescriptor)
        }

        fileMonitor?.cancel()
        fileMonitor = source
        source.resume()
    }

    private func stopFileMonitor() {
        fileMonitor?.cancel()
        fileMonitor = nil
    }

    func loadPatterns() async {
        await MainActor.run { loadingPatterns = true } // Ensure `loadingPatterns` is updated on the main thread

        do {
            let fileURL = try await gitIgnoreURL()
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                await MainActor.run {
                    patterns = []
                    loadingPatterns = false // Update on the main thread
                }
                return
            }

            if let content = try? String(contentsOf: fileURL) {
                let parsedPatterns = content.split(separator: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty && !$0.starts(with: "#") }
                    .map { GlobPattern(value: String($0)) }

                await MainActor.run {
                    patterns = parsedPatterns // Update `patterns` on the main thread
                    loadingPatterns = false  // Ensure `loadingPatterns` is updated on the main thread
                }
            } else {
                await MainActor.run {
                    patterns = []
                    loadingPatterns = false
                }
            }
        } catch {
            print("Error loading patterns: \(error)")
            await MainActor.run {
                patterns = []
                loadingPatterns = false
            }
        }
    }

    func getPattern(for id: UUID) -> GlobPattern? {
        return patterns.first(where: { $0.id == id })
    }

    func savePatterns() {
        Task {
            stopFileMonitor()
            defer { Task { try? await startFileMonitor() } }

            do {
                let fileURL = try await gitIgnoreURL()
                guard let fileContent = try? String(contentsOf: fileURL) else {
                    writeAllPatterns()
                    return
                }

                let lines = fileContent.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
                let (patternToLineIndex, nonPatternLines) = mapLines(lines)
                let globalCommentLines = extractGlobalComments(nonPatternLines, patternToLineIndex)

                var reorderedLines = reorderPatterns(globalCommentLines, patternToLineIndex, nonPatternLines, lines)

                // Ensure single blank line at the end
                reorderedLines = cleanUpWhitespace(in: reorderedLines)

                // Write the updated content back to the file
                let updatedContent = reorderedLines.joined(separator: "\n")
                try updatedContent.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Error saving patterns: \(error)")
            }
        }
    }

    private func mapLines(_ lines: [String]) -> ([String: Int], [(line: String, index: Int)]) {
        var patternToLineIndex: [String: Int] = [:]
        var nonPatternLines: [(line: String, index: Int)] = []

        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") {
                patternToLineIndex[trimmedLine] = index
            } else if index != lines.count - 1 {
                nonPatternLines.append((line: line, index: index))
            }
        }

        return (patternToLineIndex, nonPatternLines)
    }

    private func extractGlobalComments(
        _ nonPatternLines: [(line: String, index: Int)],
        _ patternToLineIndex: [String: Int]
    ) -> [String] {
        let globalComments = nonPatternLines.filter { $0.index < (patternToLineIndex.values.min() ?? Int.max) }
        return globalComments.map(\.line)
    }

    private func reorderPatterns(
        _ globalCommentLines: [String],
        _ patternToLineIndex: [String: Int],
        _ nonPatternLines: [(line: String, index: Int)],
        _ lines: [String]
    ) -> [String] {
        var reorderedLines: [String] = globalCommentLines
        var usedNonPatternLines = Set<Int>()
        var usedPatterns = Set<String>()

        for pattern in patterns {
            let value = pattern.value

            // Insert the pattern
            reorderedLines.append(value)
            usedPatterns.insert(value)

            // Preserve associated non-pattern lines
            if let currentIndex = patternToLineIndex[value] {
                for nextIndex in (currentIndex + 1)..<lines.count {
                    if let nonPatternLine = nonPatternLines.first(where: { $0.index == nextIndex }),
                       !usedNonPatternLines.contains(nonPatternLine.index) {
                        reorderedLines.append(nonPatternLine.line)
                        usedNonPatternLines.insert(nonPatternLine.index)
                    } else {
                        break
                    }
                }
            }
        }

        // Retain non-pattern lines that follow deleted patterns
        for (line, index) in nonPatternLines {
            if !usedNonPatternLines.contains(index) && !reorderedLines.contains(line) {
                reorderedLines.append(line)
                usedNonPatternLines.insert(index)
            }
        }

        // Add new patterns that were not in the original file
        for pattern in patterns where !usedPatterns.contains(pattern.value) {
            reorderedLines.append(pattern.value)
        }

        return reorderedLines
    }

    private func writeAllPatterns() {
        Task {
            do {
                let fileURL = try await gitIgnoreURL()
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    FileManager.default.createFile(atPath: fileURL.path, contents: nil)
                }

                let content = patterns.map(\.value).joined(separator: "\n")
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Failed to write all patterns: \(error)")
            }
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
        patterns.append(GlobPattern(value: ""))
    }

    @MainActor
    func removePatterns(_ selection: Set<UUID>? = nil) {
        let patternsToRemove = selection?.compactMap { getPattern(for: $0) } ?? []
        patterns.removeAll { patternsToRemove.contains($0) }
        self.selection.removeAll()
    }
}
