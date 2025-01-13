//
//  CEWorkspaceFileManager+Error.swift
//  CodeEdit
//
//  Created by Khan Winter on 1/13/25.
//

import Foundation

extension CEWorkspaceFileManager {
    enum FileManagerError: LocalizedError {
        case fileNotFound
        case fileNotIndexed
        case originFileNotFound

        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "File not found"
            case .fileNotIndexed:
                return "File not found in CodeEdit"
            case .originFileNotFound:
                return "Failed to find origin file"
            }
        }

        var helpAnchor: String? {
            switch self {
            case .fileNotIndexed:
                return "Reopen the workspace to reindex the file system."
            case .fileNotFound, .originFileNotFound:
                return "The file may have moved during the operation, try again."
            }
        }
    }
}
