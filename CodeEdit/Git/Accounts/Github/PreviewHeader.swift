//
//  PreviewHeader.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)

/// Some APIs provide additional data for new (preview) APIs if a custom header is added to the request.
///
/// - Note: Preview APIs are subject to change.
enum PreviewHeader {
    /// The `Reactions` preview header provides reactions in `Comment`s.
    case reactions

    var header: HTTPHeader {
        switch self {
        case .reactions:
            return HTTPHeader(headerField: "Accept", value: "application/vnd.github.squirrel-girl-preview")
        }
    }
}
