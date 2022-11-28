//
//  Comment.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

struct Comment: Codable {
    let id: Int
    let url: URL
    let htmlURL: URL
    let body: String
    let user: GitHubUser
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, url, body, user
        case htmlURL = "html_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
