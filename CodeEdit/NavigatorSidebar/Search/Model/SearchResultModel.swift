//
//  SearchResultModel.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import Foundation
import WorkspaceClient

struct SearchResultModel: Hashable {
    let file: WorkspaceClient.FileItem
    let lineNumber: Int?
    let lineContent: String?
    let keywordRange: Range<String.Index>?

    var hasKeywordInfo: Bool {
        return lineNumber != nil && lineContent != nil && keywordRange != nil
    }
}
