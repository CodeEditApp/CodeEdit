//
//  ChangedFile.swift
//
//
//  Created by Nanashi Li on 2022/05/20.
//

import Foundation

/// Represents a single changed file in the working tree.
public struct GitChangedFile: Identifiable, Hashable {
    public var id: String { fileURL.relativePath }

    /// The status of the file.
    public let status: GitStatus
    /// The staged status of the file. A non-`none` value here and in ``status`` may indicate a file that was added
    /// but has since been changed and needs to be re-added before committing.
    public let stagedStatus: GitStatus

    /// URL of the file
    public let fileURL: URL

    /// The original file name if ``status`` or ``stagedStatus`` is `renamed` or `copied`
    public let originalFilename: String?

    /// Returns the user-facing status, if ``status`` is `none`, returns ``stagedStatus``.
    public func anyStatus() -> GitStatus {
        if case .none = status {
            return stagedStatus
        }
        return status
    }

    public var isStaged: Bool {
        stagedStatus != .none
    }

    /// Use this string to find matching `CEWorkspaceFile`s in the workspace file manager.
    public var ceFileKey: String {
        fileURL.absoluteURL.path(percentEncoded: false)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(fileURL)
    }

    public init(
        status: GitStatus,
        stagedStatus: GitStatus,
        fileURL: URL,
        originalFilename: String?
    ) {
        self.status = status
        self.stagedStatus = stagedStatus
        self.fileURL = fileURL
        self.originalFilename = originalFilename
    }
}
