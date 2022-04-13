//
//  GitlabAccount.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public let gitlabBaseURL = "https://gitlab.com/api/v4/"
public let gitlabWebURL = "https://gitlab.com/"

public struct GitlabAccount {
    public let configuration: Configuration

    public init(_ config: Configuration = GitlabTokenConfiguration()) {
        configuration = config
    }
}
