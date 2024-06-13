//
//  LanguageClient+DocumentLink.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
//    func requestDocumentLink() async -> DocumentLinkResponse {
//        do {
//            // TODO: DocumentLinkParams IS MISSING `textDocument: TextDocumentIdentifier;` FIELD IN LSP LIBRARY
//        } catch {
//            print("requestDocumentLink Error: \(error)")
//        }
//        return []
//    }

    func requestDocumentLinkResolve(_ documentLink: DocumentLink) async -> DocumentLink? {
        do {
            return try await lspInstance.documentLinkResolve(documentLink)
        } catch {
            print("requestDocumentLinkResolve Error: \(error)")
        }
        return nil
    }
}
