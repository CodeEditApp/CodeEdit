//
//  LanguageServer+Rename.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import LanguageServerProtocol

extension LanguageServer {
    /// Setup and test the validity of a rename operation at a given location
    func requestPrepareRename(for documentURI: String, _ position: Position) async throws -> PrepareRenameResponse {
        do {
            let params = TextDocumentPositionParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position
            )
            return try await lspInstance.prepareRename(params)
        } catch {
            logger.warning("requestPrepareRename: Error \(error)")
            throw error
        }
    }

    /// Ask the server to compute a workspace change so that the client can perform a workspace-wide rename of a symbol
    func requestRename(
        for documentURI: String,
        position: Position,
        newName name: String
    ) async throws -> RenameResponse {
        do {
            let params = RenameParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position,
                newName: name
            )
            return try await lspInstance.rename(params)
        } catch {
            logger.warning("requestRename: Error \(error)")
            throw error
        }
    }
}
