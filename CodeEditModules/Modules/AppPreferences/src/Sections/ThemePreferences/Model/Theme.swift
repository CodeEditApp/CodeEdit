//
//  Theme.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI
import CodeEditTextView

// swiftlint:disable file_length

/// # Theme
///
/// The model structure of themes for the editor & terminal emulator
public struct Theme: Identifiable, Codable, Equatable, Hashable, Loopable {

    enum CodingKeys: String, CodingKey {
        case author, license, distributionURL, name, displayName, editor, terminal, version
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

    /// The `unique name` of the theme
    public var name: String

    /// The `display name` of the theme
    public var displayName: String

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
        displayName: String,
        appearance: ThemeType,
        version: String
    ) {
        self.author = author
        self.license = license
        self.metadataDescription = metadataDescription
        self.distributionURL = distributionURL
        self.name = name
        self.displayName = displayName
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
    enum ThemeType: String, Codable, Hashable {
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
    struct Attributes: Codable, Equatable, Hashable, Loopable {

        /// The 24-bit hex string of the color (e.g. #123456)
        public var color: String

        public init(color: String) {
            self.color = color
        }

        /// The `SwiftUI` of ``color``
        public var swiftColor: Color {
            get {
                Color(hex: color)
            }
            set {
                self.color = newValue.hexString
            }
        }

        /// The `NSColor` of ``color``
        public var nsColor: NSColor {
            get {
                NSColor(hex: color)
            }
            set {
                self.color = newValue.hexString
            }
        }
    }
}

public extension Theme {
    /// The editor colors of the theme
    struct EditorColors: Codable, Hashable, Loopable {

        public var editorTheme: EditorTheme {
            get {
                .init(text: text.nsColor,
                      insertionPoint: insertionPoint.nsColor,
                      invisibles: invisibles.nsColor,
                      background: background.nsColor,
                      lineHighlight: lineHighlight.nsColor,
                      selection: selection.nsColor,
                      keywords: keywords.nsColor,
                      commands: commands.nsColor,
                      types: types.nsColor,
                      attributes: attributes.nsColor,
                      variables: variables.nsColor,
                      values: values.nsColor,
                      numbers: numbers.nsColor,
                      strings: strings.nsColor,
                      characters: characters.nsColor,
                      comments: comments.nsColor)
            }
            set {
                self.text.nsColor = newValue.text
                self.insertionPoint.nsColor = newValue.insertionPoint
                self.invisibles.nsColor = newValue.invisibles
                self.background.nsColor = newValue.background
                self.lineHighlight.nsColor = newValue.lineHighlight
                self.selection.nsColor = newValue.selection
                self.keywords.nsColor = newValue.keywords
                self.commands.nsColor = newValue.commands
                self.types.nsColor = newValue.types
                self.attributes.nsColor = newValue.attributes
                self.variables.nsColor = newValue.variables
                self.values.nsColor = newValue.values
                self.numbers.nsColor = newValue.numbers
                self.strings.nsColor = newValue.strings
                self.characters.nsColor = newValue.characters
                self.comments.nsColor = newValue.comments
            }
        }

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

        /// Allows to look up properties by their name
        ///
        /// **Example:**
        /// ```swift
        /// editor["text"]
        /// // equal to calling
        /// editor.text
        /// ```
        public subscript(key: String) -> Attributes {
            get {
                switch key {
                case "text": return self.text
                case "insertionPoint": return self.insertionPoint
                case "invisibles": return self.invisibles
                case "background": return self.background
                case "lineHighlight": return self.lineHighlight
                case "selection": return self.selection
                case "keywords": return self.keywords
                case "commands": return self.commands
                case "types": return self.types
                case "attributes": return self.attributes
                case "variables": return self.variables
                case "values": return self.values
                case "numbers": return self.numbers
                case "strings": return self.strings
                case "characters": return self.characters
                case "comments": return self.comments
                default: fatalError("Invalid key")
                }
            }
            set {
                switch key {
                case "text": self.text = newValue
                case "insertionPoint": self.insertionPoint = newValue
                case "invisibles": self.invisibles = newValue
                case "background": self.background = newValue
                case "lineHighlight": self.lineHighlight = newValue
                case "selection": self.selection = newValue
                case "keywords": self.keywords = newValue
                case "commands": self.commands = newValue
                case "types": self.types = newValue
                case "attributes": self.attributes = newValue
                case "variables": self.variables = newValue
                case "values": self.values = newValue
                case "numbers": self.numbers = newValue
                case "strings": self.strings = newValue
                case "characters": self.characters = newValue
                case "comments": self.comments = newValue
                default: fatalError("Invalid key")
                }
            }
        }

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
    struct TerminalColors: Codable, Hashable, Loopable {
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

        // swiftlint:disable function_body_length
        /// Allows to look up properties by their name
        ///
        /// **Example:**
        /// ```swift
        /// terminal["text"]
        /// // equal to calling
        /// terminal.text
        /// ```
        public subscript(key: String) -> Attributes {
            get {
                switch key {
                case "text": return self.text
                case "boldText": return self.boldText
                case "cursor": return self.cursor
                case "background": return self.background
                case "selection": return self.selection
                case "black": return self.black
                case "red": return self.red
                case "green": return self.green
                case "yellow": return self.yellow
                case "blue": return self.blue
                case "magenta": return self.magenta
                case "cyan": return self.cyan
                case "white": return self.white
                case "brightBlack": return self.brightBlack
                case "brightRed": return self.brightRed
                case "brightGreen": return self.brightGreen
                case "brightYellow": return self.brightYellow
                case "brightBlue": return self.brightBlue
                case "brightMagenta": return self.brightMagenta
                case "brightCyan": return self.brightCyan
                case "brightWhite": return self.brightWhite
                default: fatalError("Invalid key")
                }
            }
            set {
                switch key {
                case "text": self.text = newValue
                case "boldText": self.boldText = newValue
                case "cursor": self.cursor = newValue
                case "background": self.background = newValue
                case "selection": self.selection = newValue
                case "black": self.black = newValue
                case "red": self.red = newValue
                case "green": self.green = newValue
                case "yellow": self.yellow = newValue
                case "blue": self.blue = newValue
                case "magenta": self.magenta = newValue
                case "cyan": self.cyan = newValue
                case "white": self.white = newValue
                case "brightBlack": self.brightBlack = newValue
                case "brightRed": self.brightRed = newValue
                case "brightGreen": self.brightGreen = newValue
                case "brightYellow": self.brightYellow = newValue
                case "brightBlue": self.brightBlue = newValue
                case "brightMagenta": self.brightMagenta = newValue
                case "brightCyan": self.brightCyan = newValue
                case "brightWhite": self.brightWhite = newValue
                default: fatalError("Invalid key")
                }
            }
        }

        public init(
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
