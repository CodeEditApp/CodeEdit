//
//  AvatarURL.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

class AvatarURL: Codable {
    var url: URL?

    init(_ json: [String: AnyObject]) {
        if let urlString = json["url"] as? String, let urlFromString = URL(string: urlString) {
            url = urlFromString
        }
    }
}
