//
//  LanguageClient+Rename.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import LanguageServerProtocol

extension LanguageServer {
    /// Setup and test the validity of a rename operation at a given location
    func requestPrepareRename(document documentURI: String, _ position: Position) async -> PrepareRenameResponse {
        do {
            let params = TextDocumentPositionParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position
            )
            return try await lspInstance.prepareRename(params)
        } catch {
            print("requestInlayHint Error \(error)")
        }
        return nil
    }

    /// Ask the server to compute a workspace change so that the client can perform a workspace-wide rename of a symbol
    func requestRename(
        document documentURI: String,
        _ position: Position,
        newName name: String
    ) async -> RenameResponse {
        do {
            let params = RenameParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position,
                newName: name
            )
            return try await lspInstance.rename(params)
        } catch {
            print("requestInlayHint Error \(error)")
        }
        return nil
    }
}
