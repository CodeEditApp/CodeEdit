//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

// MARK: - Theme
public struct Theme: Identifiable, Codable, Equatable {

    public static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.id == rhs.id
    }

    public var id: String { metadata.name }

    public var text: Attributes
    public var insertionPoint: Attributes
    public var invisibles: Attributes
    public var background: Attributes
    public var lineHighlight: Attributes
    public var selection: Attributes
    public var keywords: Attributes
    public var commands: Attributes
    public var types: Attributes
    public var attributes: Attributes
    public var variables: Attributes
    public var values: Attributes
    public var numbers: Attributes
    public var strings: Attributes
    public var characters: Attributes
    public var comments: Attributes
    public var metadata: Metadata

    public init(
        text: Attributes,
        insertionPoint: Attributes,
        invisibles: Attributes,
        background: Attributes,
        lineHighlight: Attributes,
        selection: Attributes,
        keywords: Attributes,
        commands: Attributes,
        types: Attributes,
        attributes: Attributes,
        variables: Attributes,
        values: Attributes,
        numbers: Attributes,
        strings: Attributes,
        characters: Attributes,
        comments: Attributes,
        metadata: Metadata
    ) {
        self.text = text
        self.insertionPoint = insertionPoint
        self.invisibles = invisibles
        self.background = background
        self.lineHighlight = lineHighlight
        self.selection = selection
        self.keywords = keywords
        self.commands = commands
        self.types = types
        self.attributes = attributes
        self.variables = variables
        self.values = values
        self.numbers = numbers
        self.strings = strings
        self.characters = characters
        self.comments = comments
        self.metadata = metadata
    }
}

// MARK: - Attributes
public struct Attributes: Codable {
    public var color: String

    public init(color: String) {
        self.color = color
    }

    public internal(set) var swiftColor: Color {
        get {
            Color(hex: color)
        }
        set {
            self.color = newValue.hexString
        }
    }
}

// MARK: - Metadata
public struct Metadata: Codable {
    public var author, license, metadataDescription: String
    public var distributionUrl: String
    public var name: String
    public var darkTheme: Bool

    enum CodingKeys: String, CodingKey {
        case author, license
        case metadataDescription = "description"
        case distributionUrl = "distributionURL"
        case name
        case darkTheme
    }

    public init(
        author: String,
        license: String,
        metadataDescription: String,
        distributionUrl: String,
        name: String,
        darkTheme: Bool
    ) {
        self.author = author
        self.license = license
        self.metadataDescription = metadataDescription
        self.distributionUrl = distributionUrl
        self.name = name
        self.darkTheme = darkTheme
    }
}
