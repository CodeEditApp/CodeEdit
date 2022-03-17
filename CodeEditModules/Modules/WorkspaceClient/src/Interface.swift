//
//  Interface.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 16/03/22.
//

import Combine
import Foundation

public struct WorkspaceClient {
    public var getFiles: AnyPublisher<[FileItem], Never>

    public var getFileItem: (_ id: String) throws -> FileItem

    public init(
        getFiles: AnyPublisher<[FileItem], Never>,
        getFileItem: @escaping (_ id: String) throws -> FileItem
    ) {
        self.getFiles = getFiles
        self.getFileItem = getFileItem
    }

    enum WorkspaceClientError: Error {
        case fileNotExist
    }
}
