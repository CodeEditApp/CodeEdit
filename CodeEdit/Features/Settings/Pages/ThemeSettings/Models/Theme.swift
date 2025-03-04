//
//  Theme.swift
//  CodeEditModules/Settings
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI
import CodeEditSourceEditor

// swiftlint:disable file_length

/// # Theme
///
/// The model structure of themes for the editor & terminal emulator
struct Theme: Identifiable, Codable, Equatable, Hashable, Loopable {
    enum CodingKeys: String, CodingKey {
        case author, license, distributionURL, name, displayName, editor, terminal, version
        case appearance = "type"
        case metadataDescription = "description"
    }

    static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.id == rhs.id
    }

    /// The `id` of the theme
    var id: String { self.name }

    /// The `author` of the theme
    var author: String

    /// The `license` of the theme
    var license: String

    /// A short `description` of the theme
    var metadataDescription: String

    /// An URL for reference
    var distributionURL: String

    /// If the theme is bundled with CodeEdit or not
    var isBundled: Bool = false

    /// The URL for the theme file
    var fileURL: URL?

    /// The `unique name` of the theme
    var name: String

    /// The `display name` of the theme
    var displayName: String

    /// The `version` of the theme
    var version: String

    /// The ``ThemeType`` of the theme
    ///
    /// Appears as `"type"` in the `settings.json`
    var appearance: ThemeType

    /// Editor colors of the theme
    var editor: EditorColors

    /// Terminal colors of the theme
    var terminal: TerminalColors

    init(
        editor: EditorColors,
        terminal: TerminalColors,
        author: String,
        license: String,
        metadataDescription: String,
        distributionURL: String,
        isBundled: Bool,
        name: String,
        displayName: String,
        appearance: ThemeType,
        version: String
    ) {
        self.author = author
        self.license = license
        self.metadataDescription = metadataDescription
        self.distributionURL = distributionURL
        self.isBundled = isBundled
        self.name = name
        self.displayName = displayName
        self.appearance = appearance
        self.version = version
        self.editor = editor
        self.terminal = terminal
    }
}

extension Theme {
    /// The type of the theme
    /// - **dark**: this is a theme for dark system appearance
    /// - **light**: this is a theme for light system appearance
    enum ThemeType: String, Codable, Hashable {
        case dark
        case light
    }
}

// MARK: - Attributes
extension Theme {
    /// Attributes of a certain field
    ///
    /// As of now it only includes the colors `hex` string and
    /// an accessor for a `SwiftUI` `Color`.
    struct Attributes: Codable, Equatable, Hashable, Loopable {

        /// The 24-bit hex string of the color (e.g. #123456)
        var color: String
        var bold: Bool
        var italic: Bool

        init(color: String, bold: Bool = false, italic: Bool = false) {
            self.color = color
            self.bold = bold
            self.italic = italic
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.color = try container.decode(String.self, forKey: .color)
            self.bold = try container.decodeIfPresent(Bool.self, forKey: .bold) ?? false
            self.italic = try container.decodeIfPresent(Bool.self, forKey: .italic) ?? false
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(color, forKey: .color)

            if bold {
                try container.encode(bold, forKey: .bold)
            }

            if italic {
                try container.encode(italic, forKey: .italic)
            }
        }

        enum CodingKeys: String, CodingKey {
            case color
            case bold
            case italic
        }

        /// The `SwiftUI` of ``color``
        var swiftColor: Color {
            get {
                Color(hex: color)
            }
            set {
                self.color = newValue.hexString
            }
        }

        /// The `NSColor` of ``color``
        var nsColor: NSColor {
            get {
                NSColor(hex: color)
            }
            set {
                self.color = newValue.hexString
            }
        }
    }
}

extension Theme {
    /// The editor colors of the theme
    struct EditorColors: Codable, Hashable, Loopable {

        var editorTheme: EditorTheme {
            get {
                .init(
                    text: .init(color: text.nsColor),
                    insertionPoint: insertionPoint.nsColor,
                    invisibles: .init(color: invisibles.nsColor),
                    background: background.nsColor,
                    lineHighlight: lineHighlight.nsColor,
                    selection: selection.nsColor,
                    keywords: .init(color: keywords.nsColor),
                    commands: .init(color: commands.nsColor),
                    types: .init(color: types.nsColor),
                    attributes: .init(color: attributes.nsColor),
                    variables: .init(color: variables.nsColor),
                    values: .init(color: values.nsColor),
                    numbers: .init(color: numbers.nsColor),
                    strings: .init(color: strings.nsColor),
                    characters: .init(color: characters.nsColor),
                    comments: .init(color: comments.nsColor)
                )
            }
            set {
                self.text.nsColor = newValue.text.color
                self.insertionPoint.nsColor = newValue.insertionPoint
                self.invisibles.nsColor = newValue.invisibles.color
                self.background.nsColor = newValue.background
                self.lineHighlight.nsColor = newValue.lineHighlight
                self.selection.nsColor = newValue.selection
                self.keywords.nsColor = newValue.keywords.color
                self.commands.nsColor = newValue.commands.color
                self.types.nsColor = newValue.types.color
                self.attributes.nsColor = newValue.attributes.color
                self.variables.nsColor = newValue.variables.color
                self.values.nsColor = newValue.values.color
                self.numbers.nsColor = newValue.numbers.color
                self.strings.nsColor = newValue.strings.color
                self.characters.nsColor = newValue.characters.color
                self.comments.nsColor = newValue.comments.color
            }
        }

        var text: Attributes
        var insertionPoint: Attributes
        var invisibles: Attributes
        var background: Attributes
        var lineHighlight: Attributes
        var selection: Attributes
        var keywords: Attributes
        var commands: Attributes
        var types: Attributes
        var attributes: Attributes
        var variables: Attributes
        var values: Attributes
        var numbers: Attributes
        var strings: Attributes
        var characters: Attributes
        var comments: Attributes

        /// Allows to look up properties by their name
        ///
        /// **Example:**
        /// ```swift
        /// editor["text"]
        /// // equal to calling
        /// editor.text
        /// ```
        subscript(key: String) -> Attributes {
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

        init(
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

extension Theme {
    /// The terminal emulator colors of the theme
    struct TerminalColors: Codable, Hashable, Loopable {
        var text: Attributes
        var boldText: Attributes
        var cursor: Attributes
        var background: Attributes
        var selection: Attributes
        var black: Attributes
        var red: Attributes
        var green: Attributes
        var yellow: Attributes
        var blue: Attributes
        var magenta: Attributes
        var cyan: Attributes
        var white: Attributes
        var brightBlack: Attributes
        var brightRed: Attributes
        var brightGreen: Attributes
        var brightYellow: Attributes
        var brightBlue: Attributes
        var brightMagenta: Attributes
        var brightCyan: Attributes
        var brightWhite: Attributes

        var ansiColors: [String] {
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

        /// Allows to look up properties by their name
        ///
        /// **Example:**
        /// ```swift
        /// terminal["text"]
        /// // equal to calling
        /// terminal.text
        /// ```
        subscript(key: String) -> Attributes {
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
