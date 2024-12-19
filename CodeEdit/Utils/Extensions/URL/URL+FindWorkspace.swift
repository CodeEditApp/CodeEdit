//
//  URL+FindWorkspace.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/19/24.
//

import Foundation

extension URL {
    /// Finds a workspace that contains the url.
    func findWorkspace() -> WorkspaceDocument? {
        CodeEditDocumentController.shared.documents.first(where: { doc in
            guard let workspace = doc as? WorkspaceDocument else { return false }
            // createIfNotFound is safe here because it will still exit if the file and the workspace
            // do not share a path prefix
            return workspace.workspaceFileManager?.getFile(absolutePath, createIfNotFound: true) != nil
        }) as? WorkspaceDocument
    }
}
