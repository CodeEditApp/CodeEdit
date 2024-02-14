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
//            // TODO: LOGGING
//            print("requestPrepareCallHierarchy: Error \(error)")
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
//            // TODO: LOGGING
//            print("requestCallHierarchyIncomingCalls: Error \(error)")
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
            // TODO: LOGGING
            print("requestCallHierarchyOutgoingCalls: Error \(error)")
        }
        return []
    }
}
