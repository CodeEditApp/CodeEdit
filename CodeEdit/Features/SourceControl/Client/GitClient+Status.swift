//
//  GitClient+Status.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation

/// Methods for parsing git's porcelain v2 format and returning the info in a ``GitClient/Status`` struct.
///
/// Git defines five types of changes to parse in the v2 format:
/// - Ordinary
/// - Renamed/Copied
/// - Unmerged
/// - Untracked
/// - Ignored
///
/// These are documented here: https://git-scm.com/docs/git-status.
///
/// There is one method for each change type that can be returned with the exception of ignored which is, well, ignored.
///
/// # TODO:
/// In the future, this method should return information about push/pull status and stash status, as that
/// information can be included in the same call.

extension GitClient {
    struct Status {
        var changedFiles: [GitChangedFile]
        var unmergedChanges: [GitChangedFile]
        var untrackedFiles: [GitChangedFile]
    }

    /// Fetches and parses the git repository's status.
    /// - Returns: A ``GitClient/Status`` struct with information about the changed files in the repository.
    /// - Throws: Can throw ``GitClient/GitClientError`` errors if it finds unexpected output.
    func getStatus() async throws -> Status {
        let output = try await run("status -z --porcelain=2 -u")
        return try parseStatusString(output)
    }

    /// Parses a status string from ``getStatus()`` and returns a ``Status`` object if possible.
    /// - Parameter output: The git output from running `status`. Expects a porcelain v2 string.
    /// - Returns: A status object if parseable.
    func parseStatusString(_ output: borrowing String) throws -> Status {
        let endsInNull = output.last == Character(UnicodeScalar(0))
        let endIndex: String.Index
        if endsInNull && output.count > 1 {
            endIndex = output.index(before: output.endIndex)
        } else {
            endIndex = output.endIndex
        }

        var status = Status(changedFiles: [], unmergedChanges: [], untrackedFiles: [])

        var index = output.startIndex
        while index < endIndex {
            let typeIndex = index

            // Move ahead no matter what.
            guard let nextIndex = output.safeOffset(index, offsetBy: 2) else {
                throw GitClientError.statusParseEarlyEnd
            }
            index = nextIndex

            switch output[typeIndex] {
            case "1": // Ordinary changes
                status.changedFiles.append(try parseOrdinary(index: &index, output: output))
            case "2": // Renamed or copied changes
                status.changedFiles.append(try parseRenamed(index: &index, output: output))
            case "u": // Unmerged changes
                status.unmergedChanges.append(try parseUnmerged(index: &index, output: output))
            case "?": // Untracked files
                status.untrackedFiles.append(try parseUntracked(index: &index, output: output))
            case "!", "#": // Ignored files or Header
                try substringToNextNull(from: &index, output: output) // move the index to the next line.
            default:
                throw GitClientError.statusInvalidChangeType(output[typeIndex])
            }
        }

        return status
    }

    /// Discard changes for file
    func discardChanges(for file: URL) async throws {
        _ = try await run("restore '\(file.path(percentEncoded: false))'")
    }

    /// Discard unstaged changes
    func discardAllChanges() async throws {
        _ = try await run("restore .")
    }

    // MARK: - Parsing Helpers

    // Note for the following methods we make extensive use of the `borrowing` parameter modifier to avoid
    // ever copying the output. If changes are made to these methods, ensure this invariant is maintained for
    // performance.

    /// Finds the substring up until the next null character. Does not include the null char.
    /// - Parameters:
    ///   - index: The current index. Modified to be after the null char.
    ///   - output: The string from the git command, borrowed.
    /// - Returns: A substring with the contents of the string up until a null char.
    /// - Throws: Throws a `GitClientError` if the end of the string is found early.
    @discardableResult
    fileprivate func substringToNextNull(from index: inout String.Index, output: borrowing String) throws -> Substring {
        let startIndex = index
        while output[index] != Character(UnicodeScalar(0)) {
            let newIndex = output.index(after: index)
            guard newIndex < output.endIndex else {
                throw GitClientError.statusParseEarlyEnd
            }
            index = newIndex
        }
        defer {
            if index < output.index(before: output.endIndex) {
                index = output.index(after: index)
            }
        }
        return output[startIndex..<index]
    }

    /// Move the index to the next space char.
    /// - Throws: Throws a `GitClientError` if the end of the string is found early.
    fileprivate func moveToNextSpace(from index: inout String.Index, output: borrowing String) throws {
        repeat {
            try moveOneChar(from: &index, output: output)
        }
        while output[index] != " "
    }

    /// Move the index one character.
    /// - Throws: Throws a `GitClientError` if the end of the string is found early.
    fileprivate func moveOneChar(from index: inout String.Index, output: borrowing String) throws {
        index = output.index(after: index)
        guard index != output.endIndex else {
            throw GitClientError.statusParseEarlyEnd
        }
    }

    /// Parse a status character at the current index.
    /// - Returns: The status, if any.
    /// - Throws: Throws a `GitClientError` if an invalid status character is found.
    fileprivate func parseStatus(index: inout String.Index, output: borrowing String) throws -> GitStatus {
        guard let status = GitStatus(rawValue: String(output[index])) else {
            throw GitClientError.invalidStatus(output[index])
        }
        index = output.index(after: index)
        return status
    }

    // MARK: - Change Type Parsers

    /// Parses an ordinary change.
    /// ```
    /// 1 <XY> <sub> <mH> <mI> <mW> <hH> <hI> <path>
    /// ```
    fileprivate func parseOrdinary(index: inout String.Index, output: borrowing String) throws -> GitChangedFile {
        let stagedStatus = try parseStatus(index: &index, output: output)
        let status = try parseStatus(index: &index, output: output)
        // don't care about fields
        for _ in 0..<6 {
            try moveToNextSpace(from: &index, output: output)
        }
        try moveOneChar(from: &index, output: output)
        let substring = try substringToNextNull(from: &index, output: output)
        let filename = String(substring)
        return GitChangedFile(
            status: status,
            stagedStatus: stagedStatus,
            fileURL: URL(filePath: filename, relativeTo: directoryURL),
            originalFilename: nil
        )
    }

    /// Parses a renamed or copied change.
    /// ```
    /// 2 <XY> <sub> <mH> <mI> <mW> <hH> <hI> <X><score> <path><sep><origPath>
    /// ```
    fileprivate func parseRenamed(index: inout String.Index, output: borrowing String) throws -> GitChangedFile {
        let stagedStatus = try parseStatus(index: &index, output: output)
        let status = try parseStatus(index: &index, output: output)
        // don't care about fields
        for _ in 0..<7 {
            try moveToNextSpace(from: &index, output: output)
        }
        try moveOneChar(from: &index, output: output)
        let filename = String(try substringToNextNull(from: &index, output: output))
        let originalFilename = String(try substringToNextNull(from: &index, output: output))
        return GitChangedFile(
            status: status,
            stagedStatus: stagedStatus,
            fileURL: URL(filePath: filename, relativeTo: directoryURL),
            originalFilename: originalFilename
        )
    }

    /// Parses an unmerged change.
    /// ```
    /// u <XY> <sub> <m1> <m2> <m3> <mW> <h1> <h2> <h3> <path>
    /// ```
    fileprivate func parseUnmerged(index: inout String.Index, output: borrowing String) throws -> GitChangedFile {
        let stagedStatus = try parseStatus(index: &index, output: output)
        let status = try parseStatus(index: &index, output: output)
        // don't care about fields
        for _ in 0..<8 {
            try moveToNextSpace(from: &index, output: output)
        }
        try moveOneChar(from: &index, output: output)
        let filename = String(try substringToNextNull(from: &index, output: output))
        return GitChangedFile(
            status: status,
            stagedStatus: stagedStatus,
            fileURL: URL(filePath: filename, relativeTo: directoryURL),
            originalFilename: nil
        )
    }

    /// Parses an untracked change.
    /// ```
    /// ? <path>
    /// ```
    fileprivate func parseUntracked(index: inout String.Index, output: borrowing String) throws -> GitChangedFile {
        let filename = String(try substringToNextNull(from: &index, output: output))
        return GitChangedFile(
            status: .untracked,
            stagedStatus: .none,
            fileURL: URL(filePath: filename, relativeTo: directoryURL),
            originalFilename: nil
        )
    }
}
