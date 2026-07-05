//
//  GitCommit.swift
//  CodeEditModules/Git
//
//  Created by Marco Carnevali on 27/03/22.
//

import Foundation.NSDate

/// Model class to help map commit history log data
public struct GitCommit: Equatable, Hashable, Identifiable {
    public var id: UUID
    public let hash: String
    public let commitHash: String
    public let message: String
    public let author: String
    public let authorEmail: String
    public let committer: String
    public let committerEmail: String
    public let body: String
    public let refs: [String]
    public let tag: String
    public let remoteURL: URL?
    public let date: Date

    public var commitBaseURL: URL? {
        if let remoteURL {
            if remoteURL.absoluteString.contains("github") {
                return parsedRemoteUrl(domain: "https://github.com", remote: remoteURL)
            }
            if remoteURL.absoluteString.contains("bitbucket") {
                return parsedRemoteUrl(domain: "https://bitbucket.org", remote: remoteURL)
            }
            if remoteURL.absoluteString.contains("gitlab") {
                return parsedRemoteUrl(domain: "https://gitlab.com", remote: remoteURL)
            }
            // TODO: Implement other git clients other than github, bitbucket here
        }
        return nil
    }

    private func parsedRemoteUrl(domain: String, remote: URL) -> URL {
        // There are 2 types of remotes - https and ssh. While https has URL in its name, ssh doesn't.
        // Following code takes remote name in format profileName/repoName and prepends according domain
        var formattedRemote = remote
        if formattedRemote.absoluteString.starts(with: "git@") {
            let parts = formattedRemote.absoluteString.components(separatedBy: ":")
            formattedRemote = URL.init(fileURLWithPath: "\(domain)/\(parts[parts.count - 1])")
        }

        return formattedRemote.deletingPathExtension().appending(path: "commit")
    }

    public var remoteString: String {
        if let remoteURL {
            if remoteURL.absoluteString.contains("github") {
                return "GitHub"
            }
            if remoteURL.absoluteString.contains("bitbucket") {
                return "BitBucket"
            }
            if remoteURL.absoluteString.contains("gitlab") {
                return "GitLab"
            }
        }
        return "Remote"
    }

    public init(
        id: UUID = UUID(),
        hash: String,
        commitHash: String,
        message: String,
        author: String,
        authorEmail: String,
        committer: String,
        committerEmail: String,
        body: String,
        refs: [String],
        tag: String,
        remoteURL: URL?,
        date: Date
    ) {
        self.id = id
        self.hash = hash
        self.commitHash = commitHash
        self.message = message
        self.author = author
        self.authorEmail = authorEmail
        self.committer = committer
        self.committerEmail = committerEmail
        self.body = body
        self.refs = refs
        self.tag = tag
        self.remoteURL = remoteURL
        self.date = date
    }
}
