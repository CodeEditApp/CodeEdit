//
//  RepoOutlineGroupItem.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/29/23.
//

import SwiftUI

struct RepoOutlineGroupItem: Hashable, Identifiable {
    enum ImageType: Hashable {
        case system(name: String)
        case symbol(name: String)
    }

    var id: String
    var label: String
    var description: String?
    var image: ImageType
    var imageColor: Color
    var children: [RepoOutlineGroupItem]?
    var branch: GitBranch?
    var stashEntry: GitStashEntry?
    var remote: GitRemote?
}
