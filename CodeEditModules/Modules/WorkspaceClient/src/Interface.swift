//
//  Interface.swift
//  CodeEditModules/WorkspaceClient
//
//  Created by Marco Carnevali on 16/03/22.
//

import Combine
import Foundation

// TODO: DOCS (Marco Carnevali)
// swiftlint:disable missing_docs
public struct WorkspaceClient {

    public var folderURL: () -> URL?

    public var getFiles: AnyPublisher<[FileItem], Never>

    public var getFileItem: (_ id: String) throws -> FileItem

    /// callback function that is run when a change is detected in the file system.
    /// This usually contains a `reloadData` function.
    public static var onRefresh: () -> Void = {}

    // For some strange reason, swiftlint thinks this is wrong?
    public init(
        folderURL: @escaping () -> URL?,
        getFiles: AnyPublisher<[FileItem], Never>,
        getFileItem: @escaping (_ id: String) throws -> FileItem
    ) {
        self.folderURL = folderURL
        self.getFiles = getFiles
        self.getFileItem = getFileItem
    }
    // swiftlint:enable vertical_parameter_alignment

    enum WorkspaceClientError: Error {
        case fileNotExist
    }
}
