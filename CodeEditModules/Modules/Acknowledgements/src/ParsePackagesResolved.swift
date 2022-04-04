//
//  ParsePackagesResolved.swift
//
//
//  Created by Shivesh M M on 4/4/22.
//

import Foundation

//   let parsedJSON = try? JSONDecoder().decode(RootObject.self, from: jsonData)
struct Dependency: Decodable {
    var name: String
    var repositoryLink: String
    var version: String
    var repositoryURL: URL {
        return URL(string: repositoryLink)!
    }
}

struct RootObject: Codable {
    let object: Object
    let version: Int
}

// MARK: - Object
struct Object: Codable {
    let pins: [Pin]
}

// MARK: - Pin
struct Pin: Codable {
    let package: String
    let repositoryURL: String
    let state: State
}

// MARK: - State
struct State: Codable {
    let revision, version: String
}
