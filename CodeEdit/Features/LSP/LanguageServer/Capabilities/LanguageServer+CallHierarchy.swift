//
//  LanguageServer+CallHierarchy.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestPrepareCallHierarchy(
        for documentURI: String, position: Position
    ) async throws -> CallHierarchyPrepareResponse {
        do {
            let prepareParams = CallHierarchyPrepareParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position,
                workDoneToken: nil
            )
            return try await lspInstance.prepareCallHierarchy(prepareParams)
        } catch {
            logger.warning("requestPrepareCallHierarchy: Error \(error)")
            throw error
        }
    }

    func requestCallHierarchyIncomingCalls(
        _ callHierarchyItem: CallHierarchyItem
    ) async throws -> CallHierarchyIncomingCallsResponse {
        do {
            let incomingParams = CallHierarchyIncomingCallsParams(
                item: callHierarchyItem,
                workDoneToken: nil
            )
            return try await lspInstance.callHierarchyIncomingCalls(incomingParams)
        } catch {
            logger.warning("requestCallHierarchyIncomingCalls: Error \(error)")
            throw error
        }
    }

    func requestCallHierarchyOutgoingCalls(
        _ callHierarchyItem: CallHierarchyItem
    ) async throws -> CallHierarchyOutgoingCallsResponse {
        do {
            let outgoingParams = CallHierarchyOutgoingCallsParams(
                item: callHierarchyItem,
                workDoneToken: nil
            )
            return try await lspInstance.callHierarchyOutgoingCalls(outgoingParams)
        } catch {
            logger.warning("requestCallHierarchyOutgoingCalls: Error \(error)")
            throw error
        }
    }
}
