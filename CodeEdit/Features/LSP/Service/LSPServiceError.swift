//
//  LSPServiceError.swift
//  CodeEdit
//
//  Created by Khan Winter on 3/24/25.
//

enum LSPServiceError: Error {
    case serverNotFound
    case serverStartFailed
    case serverStopFailed
    case languageClientNotFound
}
