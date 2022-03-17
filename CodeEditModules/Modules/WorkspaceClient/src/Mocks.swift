//
//  File.swift
//  
//
//  Created by Marco Carnevali on 16/03/22.
//

import Foundation

public extension WorkspaceClient {
    static var empty = Self(
		folderURL: { nil },
        getFiles: { [] },
        getFileItem: { _ in throw WorkspaceClientError.fileNotExist }
    )
}
