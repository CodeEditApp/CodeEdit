//
//  CEWorkspaceFileManager+Error.swift
//  CodeEdit
//
//  Created by Khan Winter on 1/13/25.
//

import Foundation

extension CEWorkspaceFileManager {
    /// Localized errors related to actions in the file manager.
    /// These errors are suitable for presentation using `NSAlert(error:)`.
    enum FileManagerError: LocalizedError {
        case fileNotFound
        case fileNotIndexed
        case originFileNotFound
        case destinationFileExists
        case invalidFileName

        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "File not found"
            case .fileNotIndexed:
                return "File not found in CodeEdit"
            case .originFileNotFound:
                return "Failed to find origin file"
            case .destinationFileExists:
                return "Destination already exists"
            case .invalidFileName:
                return "Invalid file name"
            }
        }

        var recoverySuggestion: String? {
            switch self {
            case .fileNotIndexed:
                return "Reopen the workspace to reindex the file system."
            case .fileNotFound, .originFileNotFound:
                return "The file may have moved during the operation, try again."
            case .destinationFileExists:
                return "Use a different file name or remove the conflicting file."
            case .invalidFileName:
                return "File names must not contain the : character and be less than 256 characters."
            }
        }
    }
}
