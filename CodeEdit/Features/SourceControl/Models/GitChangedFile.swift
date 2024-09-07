//
//  ChangedFile.swift
//  
//
//  Created by Nanashi Li on 2022/05/20.
//

import Foundation
import SwiftUI

/// Represents a single changed file in the working tree.
struct GitChangedFile: Identifiable, Hashable {
    var id: String { fileURL.relativePath }

    /// The status of the file.
    let status: GitStatus
    /// The staged status of the file. A non-`none` value here and in ``status`` may indicate a file that was added
    /// but has since been changed and needs to be re-added before committing.
    let stagedStatus: GitStatus

    /// URL of the file
    let fileURL: URL

    /// The original file name if ``status`` or ``stagedStatus`` is `renamed` or `copied`
    let originalFilename: String?

    /// Returns the user-facing status, if ``status`` is `none`, returns ``stagedStatus``.
    func anyStatus() -> GitStatus {
        if case .none = status {
            return stagedStatus
        }
        return status
    }

    var isStaged: Bool {
        stagedStatus != .none
    }

    /// Use this string to find matching `CEWorkspaceFile`s in the workspace file manager.
    var ceFileKey: String {
        fileURL.absoluteURL.path(percentEncoded: false)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileURL)
    }
}
