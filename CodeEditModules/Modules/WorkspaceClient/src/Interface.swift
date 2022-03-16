//
//  Interface.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 16/03/22.
//
import Foundation

public struct WorkspaceClient {
    
    public var getFiles: () -> [FileItem]
    
    public var getFileItem: (_ id: UUID) throws -> FileItem
    
    public init(
        getFiles: @escaping () -> [FileItem],
        getFileItem: @escaping (_ id: UUID) throws -> FileItem
    ) {
        self.getFiles = getFiles
        self.getFileItem = getFileItem
    }
    
    enum WorkspaceClientError: Error {
        case fileNotExist
    }
}
