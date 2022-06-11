//
//  PreviewHeader.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)
// swiftlint:disable missing_docs

/// Some APIs provide additional data for new (preview) APIs if a custom header is added to the request.
///
/// - Note: Preview APIs are subject to change.
public enum PreviewHeader {
    /// The `Reactions` preview header provides reactions in `Comment`s.
    case reactions

    public var header: HTTPHeader {
        switch self {
        case .reactions:
            return HTTPHeader(headerField: "Accept", value: "application/vnd.github.squirrel-girl-preview")
        }
    }
}
