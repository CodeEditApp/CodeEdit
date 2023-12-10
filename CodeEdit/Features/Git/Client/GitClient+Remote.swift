//
//  GitClient+Remote.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/17/23.
//

import Foundation

extension GitClient {
    /// Gets all remotes
    /// - Parameter name: Name for remote
    /// - Parameter location: URL string for remote location
    func getRemotes() async throws -> [GitRemote] {
        let command = "remote -v"
        let output = try await run(command)
        let remotes = parseGitRemotes(from: output)

        return remotes
    }

    /// Add existing remote to local git
    /// - Parameter name: Name for remote
    /// - Parameter location: URL string for remote location
    func addRemote(name: String, location: String) async throws {
        _ = try await run("remote add \(name) \(location)")
    }

    /// Remove remote from local git
    /// - Parameter name: Name for remote to remove
    func removeRemote(name: String) async throws {
        _ = try await run("remote rm \(name)")
    }
}

func parseGitRemotes(from output: String) -> [GitRemote] {
    var remotes: [String: (fetch: String?, push: String?)] = [:]

    output.split(separator: "\n").forEach { line in
        let components = line.split { $0 == " " || $0 == "\t" }
        guard components.count == 3 else { return }

        let name = String(components[0])
        let location = String(components[1])
        let type = components[2].contains("(fetch)") ? "fetch" : "push"

        if var remote = remotes[name] {
            if type == "fetch" {
                remote.fetch = location
            } else {
                remote.push = location
            }
            remotes[name] = remote
        } else {
            if type == "fetch" {
                remotes[name] = (fetch: location, push: nil)
            } else {
                remotes[name] = (fetch: nil, push: location)
            }
        }
    }

    return remotes.compactMap { name, locations in
        if let fetchLocation = locations.fetch, let pushLocation = locations.push {
            return GitRemote(name: name, pushLocation: pushLocation, fetchLocation: fetchLocation)
        }
        return nil
    }
}
