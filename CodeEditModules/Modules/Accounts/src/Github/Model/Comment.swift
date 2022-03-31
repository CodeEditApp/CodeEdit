//
//  Comment.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public struct Comment: Codable {
    public let id: Int
    public let url: URL
    public let htmlURL: URL
    public let body: String
    public let user: User
    public let createdAt: Date
    public let updatedAt: Date
    public let reactions: Reactions?

    enum CodingKeys: String, CodingKey {
        case id, url, body, user, reactions
        case htmlURL = "html_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
