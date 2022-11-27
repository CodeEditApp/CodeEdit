//
//  Commit.swift
//  CodeEditModules/Git
//
//  Created by Marco Carnevali on 27/03/22.
//

import Foundation.NSDate

/// Model class to help map commit history log data
struct Commit: Equatable, Hashable, Identifiable {
    var id = UUID()
    let hash: String
    let commitHash: String
    let message: String
    let author: String
    let authorEmail: String
    let commiter: String
    let commiterEmail: String
    let remoteURL: URL?
    let date: Date

    var commitBaseURL: URL? {
        if let remoteURL = remoteURL {
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
        // There are 2 types of remotes - https and ssh. While https has URL in its name, ssh doesnt.
        // Following code takes remote name in format profileName/repoName and prepends according domain
        var formattedRemote = remote
        if formattedRemote.absoluteString.starts(with: "git@") {
            let parts = formattedRemote.absoluteString.components(separatedBy: ":")
            formattedRemote = URL.init(fileURLWithPath: "\(domain)/\(parts[parts.count - 1])")
        }

        return formattedRemote.deletingPathExtension().appendingPathComponent("commit")
    }

    var remoteString: String {
        if let remoteURL = remoteURL {
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
}
