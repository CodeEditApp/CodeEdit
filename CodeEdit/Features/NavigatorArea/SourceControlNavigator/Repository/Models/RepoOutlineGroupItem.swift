//
//  RepoOutlineGroupItem.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/29/23.
//

import SwiftUI

struct RepoOutlineGroupItem: Hashable, Identifiable {
    var id: String
    var label: String
    var description: String?
    var systemImage: String?
    var symbolImage: String?
    var imageColor: Color?
    var children: [RepoOutlineGroupItem]?
    var branch: GitBranch?
    var stashEntry: GitStashEntry?
    var remote: GitRemote?
}
