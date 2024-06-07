//
//  LanguageClient+CallHierarchy.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestPrepareCallHierarchy(
        document documentURI: String, _ position: Position
    ) async -> CallHierarchyPrepareResponse {
        // TODO: SOMEHOW NEED TO INVALIDATE THIS. CURRENTLY STORING EVERYTHING IN callHierarchyItems VARIABLE
//        let prepareParams = CallHierarchyPrepareParams(
//            textDocument: TextDocumentIdentifier(uri: documentURI),
//            position: position,
//            workDoneToken: nil
//        )
//
//        do {
//            guard let items = try await server.prepareCallHierarchy(params: prepareParams) else {
//                return []
//            }
//            callHierarchyItems[documentURI] = items
//            return items
//        } catch {
//            logger.error("requestPrepareCallHierarchy: Error \(error)")
//        }

        return []
    }

    func requestCallHierarchyIncomingCalls(
        _ callHierarchyItem: CallHierarchyItem
    ) async -> CallHierarchyIncomingCallsResponse {
//        let incomingParams = CallHierarchyIncomingCallsParams(
//            item: callHierarchyItem,
//            workDoneToken: nil
//        )
//
//        do {
//            guard let incomingCalls = try await server.callHierarchyIncomingCalls(params: incomingParams) else {
//                return []
//            }
//            return incomingCalls
//        } catch {
//            logger.error("requestCallHierarchyIncomingCalls: Error \(error)")
//        }
        return []
    }

    func requestCallHierarchyOutgoingCalls(
        _ callHierarchyItem: CallHierarchyItem
    ) async -> CallHierarchyOutgoingCallsResponse {
        let outgoingParams = CallHierarchyOutgoingCallsParams(
            item: callHierarchyItem,
            workDoneToken: nil
        )

        do {
            guard let outgoingCalls = try await lspInstance.callHierarchyOutgoingCalls(outgoingParams) else {
                return []
            }
            return outgoingCalls
        } catch {
            logger.error("requestCallHierarchyOutgoingCalls: Error \(error)")
        }
        return []
    }
}
