//
//  Commit.swift
//  
//
//  Created by Marco Carnevali on 27/03/22.
//

import Foundation.NSDate

/// Model class to help map commit history log data
public struct Commit: Equatable, Hashable, Identifiable {
    public var id = UUID()
    public let hash: String
    public let commitHash: String
    public let message: String
    public let author: String
    public let authorEmail: String
    public let commiter: String
    public let commiterEmail: String
    public let remoteURL: URL?
    public let date: Date

    public var commitBaseURL: URL? {
        if let remoteURL = remoteURL {
            if remoteURL.absoluteString.contains("github") {
                return remoteURL.deletingPathExtension().appendingPathComponent("commit")
            }
            if remoteURL.absoluteString.contains("bitbucket") {
                return remoteURL.deletingPathExtension().appendingPathComponent("commits")
            }
            // TODO: Implement other git clients other than github here
        }
        return nil
    }

    public var remoteString: String {
        if let remoteURL = remoteURL {
            if remoteURL.absoluteString.contains("github") {
                return "GitHub"
            }
            if remoteURL.absoluteString.contains("bitbucket") {
                return "BitBucket"
            }
        }
        return "Remote"
    }
}
