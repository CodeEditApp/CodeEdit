//
//  GitLabAccount.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)
let gitlabBaseURL = "https://gitlab.com/api/v4/"
let gitlabWebURL = "https://gitlab.com/"

struct GitLabAccount {
    let configuration: RouterConfiguration

    init(_ config: RouterConfiguration = GitLabTokenConfiguration()) {
        configuration = config
    }
}
