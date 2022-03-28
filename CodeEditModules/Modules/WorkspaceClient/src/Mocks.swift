//
//  Mocks.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 16/03/22.
//

import Combine
import Foundation

public extension WorkspaceClient {
    static var empty = Self(
        folderURL: { nil },
        getFiles: CurrentValueSubject<[FileItem], Never>([]).eraseToAnyPublisher(),
        getFileItem: { _ in throw WorkspaceClientError.fileNotExist }
    )
}
