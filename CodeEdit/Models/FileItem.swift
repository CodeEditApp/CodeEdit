//
//  FileItem.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 12/03/2022.
//

import Foundation

struct FileItem: Hashable, Identifiable {
    var id: UUID = UUID()
    var url: URL
    var children: [FileItem]? = nil
    var systemImage: String {
        switch children {
        case nil:
            return "doc.plaintext"
        case .some(let children):
            return children.isEmpty ? "folder" : "folder.fill"
        }
    }
}
