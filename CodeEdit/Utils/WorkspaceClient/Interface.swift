//
//  Interface.swift
//  CodeEditModules/WorkspaceClient
//
//  Created by Marco Carnevali on 16/03/22.
//

import Combine
import Foundation

// TODO: DOCS (Marco Carnevali)
struct WorkspaceClient {

    var folderURL: () -> URL?

    var getFiles: AnyPublisher<[FileItem], Never>

    var getFileItem: (_ id: String) throws -> FileItem

    var addFileItem: (_ item: FileItem, FileItem?) -> Void

    var removeFileItem: (_ item:FileItem) -> Void

    /// callback function that is run when a change is detected in the file system.
    /// This usually contains a `reloadData` function.
    static var onRefresh: () -> Void = {}

    // For some strange reason, swiftlint thinks this is wrong?
    init(
        folderURL: @escaping () -> URL?,
        getFiles: AnyPublisher<[FileItem], Never>,
        getFileItem: @escaping (_ id: String) throws -> FileItem,
        addFileItem: @escaping (_ item: FileItem, FileItem?) -> Void,
        removeFileItem: @escaping(_ item: FileItem) -> Void
    ) {
        self.folderURL = folderURL
        self.getFiles = getFiles
        self.getFileItem = getFileItem
        self.addFileItem = addFileItem
        self.removeFileItem = removeFileItem
    }

    enum WorkspaceClientError: Error {
        case fileNotExist
    }
}
