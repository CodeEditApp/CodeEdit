//
//  ParsePackagesResolved.swift
//  CodeEditModules/Acknowledgements
//
//  Created by Shivesh M M on 4/4/22.
//

import Foundation

struct AcknowledgementDependency: Decodable {
    var name: String
    var repositoryLink: String
    var version: String
    var repositoryURL: URL {
        URL(string: repositoryLink)!
    }
}

struct AcknowledgementRootObject: Codable {
    let object: AcknowledgementObject
}

// MARK: - Object
struct AcknowledgementObject: Codable {
    let pins: [AcknowledgementPin]
}

// MARK: - Pin
struct AcknowledgementPin: Codable {
    let package: String
    let repositoryURL: String
    let state: AcknowledgementPackageState
}

// MARK: - State
struct AcknowledgementPackageState: Codable {
    let revision: String
    let version: String?
}
