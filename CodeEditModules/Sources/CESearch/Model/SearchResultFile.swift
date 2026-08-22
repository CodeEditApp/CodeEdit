//
//  SearchResultFile.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import Foundation

/// A lightweight, framework-free representation of a file appearing in search results.
/// Search never needs the full app file model — only identity, location, and a display name.
public struct SearchResultFile: Identifiable, Hashable, Sendable {
    public let id: String
    public let url: URL
    public let name: String

    public init(url: URL, name: String? = nil) {
        self.id = url.absoluteString
        self.url = url
        self.name = name ?? url.lastPathComponent
    }
}
