//
//  Mocks.swift
//  CodeEditModules/WorkspaceClient
//
//  Created by Marco Carnevali on 16/03/22.
//

import Combine
import Foundation

// TODO: DOCS (Marco Carnevali)
// swiftlint:disable missing_docs
public extension WorkspaceClient {
    static var empty = Self(
        folderURL: { nil },
        getFiles: CurrentValueSubject<[FileItem], Never>([]).eraseToAnyPublisher(),
        getFileItem: { _ in throw WorkspaceClientError.fileNotExist }
    )
}
