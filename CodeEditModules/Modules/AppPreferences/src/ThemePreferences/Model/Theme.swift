//
//  Theme.swift
//  
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

/// # Theme
///
/// The model structure of themes for the editor & terminal emulator
public struct Theme: Identifiable, Codable, Equatable {

    enum CodingKeys: String, CodingKey {
        case author, license, distributionURL, name, editor, terminal, version
        case appearance = "type"
        case metadataDescription = "description"
    }

    public static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.id == rhs.id
    }

    /// The `id` of the theme
    public var id: String { self.name }

    /// The `author` of the theme
    public var author: String

    /// The `licence` of the theme
    public var license: String

    /// A short `description` of the theme
    public var metadataDescription: String

    /// An URL for reference
    public var distributionURL: String

    /// The `display name` of the theme
    public var name: String

    /// The `version` of the theme
    public var version: String

    /// The ``ThemeType`` of the theme
    ///
    /// Appears as `"type"` in the `preferences.json`
    public var appearance: ThemeType

    /// Editor colors of the theme
    public var editor: EditorColors

    /// Terminal colors of the theme
    public var terminal: TerminalColors

    public init(
        editor: EditorColors,
        terminal: TerminalColors,
        author: String,
        license: String,
        metadataDescription: String,
        distributionURL: String,
        name: String,
        appearance: ThemeType,
        version: String
    ) {
        self.author = author
        self.license = license
        self.metadataDescription = metadataDescription
        self.distributionURL = distributionURL
        self.name = name
        self.appearance = appearance
        self.version = version
        self.editor = editor
        self.terminal = terminal
    }
}

public extension Theme {
    /// The type of the theme
    /// - **dark**: this is a theme for dark system appearance
    /// - **light**: this is a theme for light system appearance
    enum ThemeType: String, Codable {
        case dark
        case light
    }
}

// MARK: - Attributes
public extension Theme {
    /// Attributes of a certain field
    ///
    /// As of now it only includes the colors `hex` string and
    /// an accessor for a `SwiftUI` `Color`.
    struct Attributes: Codable {

        /// The 24-bit hex string of the color (e.g. #123456)
        public var color: String

        public init(color: String) {
            self.color = color
        }

        /// The `SwiftUI` color
        public internal(set) var swiftColor: Color {
            get {
                Color(hex: color)
            }
            set {
                self.color = newValue.hexString
            }
        }
    }
}

public extension Theme {
    /// The editor colors of the theme
    struct EditorColors: Codable {
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
            comments: Attributes
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
        }
    }
}

public extension Theme {
    /// The terminal emulator colors of the theme
    struct TerminalColors: Codable {
        public var text: Attributes
        public var boldText: Attributes
        public var cursor: Attributes
        public var background: Attributes
        public var selection: Attributes
        public var black: Attributes
        public var red: Attributes
        public var green: Attributes
        public var yellow: Attributes
        public var blue: Attributes
        public var magenta: Attributes
        public var cyan: Attributes
        public var white: Attributes
        public var brightBlack: Attributes
        public var brightRed: Attributes
        public var brightGreen: Attributes
        public var brightYellow: Attributes
        public var brightBlue: Attributes
        public var brightMagenta: Attributes
        public var brightCyan: Attributes
        public var brightWhite: Attributes

        public var ansiColors: [String] {
            [
                black.color,
                red.color,
                green.color,
                yellow.color,
                blue.color,
                magenta.color,
                cyan.color,
                white.color,
                brightBlack.color,
                brightRed.color,
                brightGreen.color,
                brightYellow.color,
                brightBlue.color,
                brightMagenta.color,
                brightCyan.color,
                brightWhite.color,
            ]
        }

        init(
            text: Attributes,
            boldText: Attributes,
            cursor: Attributes,
            background: Attributes,
            selection: Attributes,
            black: Attributes,
            red: Attributes,
            green: Attributes,
            yellow: Attributes,
            blue: Attributes,
            magenta: Attributes,
            cyan: Attributes,
            white: Attributes,
            brightBlack: Attributes,
            brightRed: Attributes,
            brightGreen: Attributes,
            brightYellow: Attributes,
            brightBlue: Attributes,
            brightMagenta: Attributes,
            brightCyan: Attributes,
            brightWhite: Attributes
        ) {
            self.text = text
            self.boldText = boldText
            self.cursor = cursor
            self.background = background
            self.selection = selection
            self.black = black
            self.red = red
            self.green = green
            self.yellow = yellow
            self.blue = blue
            self.magenta = magenta
            self.cyan = cyan
            self.white = white
            self.brightBlack = brightBlack
            self.brightRed = brightRed
            self.brightGreen = brightGreen
            self.brightYellow = brightYellow
            self.brightBlue = brightBlue
            self.brightMagenta = brightMagenta
            self.brightCyan = brightCyan
            self.brightWhite = brightWhite
        }
    }
}
