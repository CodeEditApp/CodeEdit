//
//  GitBranchesGroup.swift
//  CodeEdit
//
//  Created by Federico Zivolo on 22/01/24.
//

import Foundation

struct GitBranchesGroup: Hashable {
    let name: String
    var branches: [GitBranch]
    var shouldNest: Bool {
        branches.first?.name.hasPrefix(name + "/") ?? false
    }
}
