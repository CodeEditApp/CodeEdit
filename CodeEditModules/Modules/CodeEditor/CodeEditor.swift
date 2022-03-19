//
//  CodeEditor.swift
//  CodeEditor
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import Highlightr

/**
 * An simple code editor (or viewer) with highlighting for SwiftUI (iOS and
 * macOS).
 *
 * To use the code editor as a Viewer, simply pass the source code
 *
 *     struct ContentView: View {
 *
 *         var body: some View {
 *             CodeEditor(source: "let a = 42")
 *         }
 *     }
 *
 * If it should act as an actual editor, pass in a `Binding`:
 *
 *     struct ContentView: View {
 *
 *         @State private var source = "let a = 42\n"
 *
 *         var body: some View {
 *             CodeEditor(source: $source, language: .swift, theme: .ocean)
 *         }
 *     }
 *
 * ### Languages and Themes
 *
 * Highlight.js supports more than 180 languages and over 80 different themes.
 *
 * The available languages and themes can be accessed using:
 *
 *     CodeEditor.availableLanguages
 *     CodeEditor.availableThemes
 *
 * They can be used in a SwiftUI `Picker` like so:
 *
 *     @State var source   = "let it = be"
 *     @State var language = CodeEditor.Language.swift
 *
 *     Picker("Language", selection: $language) {
 *       ForEach(CodeEditor.availableLanguages) { language in
 *         Text("\(language.rawValue.capitalized)")
 *           .tag(language)
 *       }
 *     }
 *
 *     CodeEditor(source: $source, language: language)
 *
 * Note: The `CodeEditor` doesn't do automatic theme changes if the appearance
 *       changes.
 *
 * ### Smart Indent and Open/Close Pairing
 *
 * Inspired by [NTYSmartTextView](https://github.com/naoty/NTYSmartTextView),
 * `CodeEditor` now also supports (on macOS):
 * - smarter indents (preserving the indent of the previous line)
 * - soft indents (insert a configurable amount of spaces if the user presses tabs)
 * - auto character pairing, e.g. when entering `{`, the matching `}` will be auto-added
 *
 * To enable smart indents, add the `smartIndent` flag, e.g.:
 *
 *     CodeEditor(source: $source, language: language,
 *                flags: [ .selectable, .editable, .smartIndent ])
 *
 * It is enabled for editors by default.
 *
 * To configure soft indents, use the `indentStyle` parameter, e.g.
 *
 *     CodeEditor(source: $source, language: language,
 *                indentStyle: .softTab(width: 2))
 *
 * It defaults to tabs, as per system settings.
 *
 * Auto character pairing is automatic based on the language. E.g. there is a set of
 * defaults for C like languages (e.g. Swift), Python or XML. The defaults can be overridden
 * using the respective static variable in `CodeEditor`,
 * or the desired pairing can be set explicitly:
 *
 *     CodeEditor(source: $source, language: language,
 *                autoPairs: [ "{": "}", "<": ">", "'": "'" ])
 *
 *
 * ### Font Sizing
 *
 * On macOS the editor supports sizing of the font (using Cmd +/Cmd - and the
 * font panel).
 * To enable sizing commands, the WindowScene needs to have the proper commands
 * applied, e.g.:
 *
 *     WindowGroup {
 *         ContentView()
 *     }
 *     .commands {
 *         TextFormattingCommands()
 *     }
 *
 * To persist the binding, the `fontSize` binding is available.
 *
 * ### Highlightr and Shaper
 *
 * Based on the excellent [Highlightr](https://github.com/raspu/Highlightr).
 * This means that it is using JavaScriptCore as the actual driver. As
 * Highlightr says:
 *
 * > It will never be as fast as a native solution, but it's fast enough to be
 * > used on a real time editor.
 *
 * The editor is similar to (but not exactly the same) the one used by
 * [SVG Shaper for SwiftUI](https://zeezide.de/en/products/svgshaper/),
 * for its SVG and Swift editor parts.
 */
public struct CodeEditor: View {
  
  /// Returns the available themes in the associated Highlightr package.
  public static var availableThemes =
    Highlightr()?.availableThemes().map(ThemeName.init).sorted() ?? []
  
  /// Returns the available languages in the associated Highlightr package.
  public static var availableLanguages =
    Highlightr()?.supportedLanguages().map(Language.init).sorted() ?? []
  

  /**
   * Flags available for `CodeEditor`, currently just:
   * - `.editable`
   * - `.selectable`
   */
  @frozen public struct Flags: OptionSet {
    public let rawValue : UInt8
    @inlinable public init(rawValue: UInt8) { self.rawValue = rawValue }
    
    /// `.editable` requires that the `source` of the `CodeEditor` is a
    /// `Binding`.
    public static let editable   = Flags(rawValue: 1 << 0)
    
    /// Whether the displayed content should be selectable by the user.
    public static let selectable = Flags(rawValue: 1 << 1)
    
    /// If the user starts a newline, the editor automagically adds the same
    /// whitespace as on the previous line.
    public static let smartIndent = Flags(rawValue: 1 << 2)
    
    public static let defaultViewerFlags : Flags = [ .selectable ]
    public static let defaultEditorFlags : Flags =
                        [ .selectable, .editable, .smartIndent ]
  }
  
  @frozen public enum IndentStyle: Equatable {
    case system
    case softTab(width: Int)
  }
  
  /**
   * Default auto pairing mappings for languages.
   */
  public static var defaultAutoPairs : [ Language : [ String : String ] ] = [
    .c: cStyleAutoPairs, .cpp: cStyleAutoPairs, .objectivec: cStyleAutoPairs,
    .swift: cStyleAutoPairs,
    .java: cStyleAutoPairs, .javascript: cStyleAutoPairs,
    .xml: xmlStyleAutoPairs,
    .python: [ "(": ")", "[": "]",  "\"": "\"",  "'": "'", "`": "`" ]
  ]
  public static var cStyleAutoPairs = [
    "(": ")", "[": "]", "{": "}", "\"": "\"",  "'": "'", "`": "`"
  ]
  public static var xmlStyleAutoPairs = [ "<": ">", "\"": "\"", "'": "'" ]


  /**
   * Configures a CodeEditor View with the given parameters.
   *
   * - Parameters:
   *   - source:      A binding to a String that holds the source code to be
   *                  edited (or displayed).
   *   - language:    Optionally set a language (e.g. `.swift`), otherwise
   *                  Highlight.js will attempt to detect the language.
   *   - theme:       The name of the theme to use, defaults to "pojoaque".
   *   - fontSize:    On macOS this Binding can be used to persist the size of
   *                  the font in use. At runtime this is combined with the
   *                  theme to produce the full font information. (optional)
   *   - flags:       Configure whether the text is editable and/or selectable
   *                  (defaults to both).
   *   - indentStyle: Optionally insert a configurable amount of spaces if the
   *                  user hits "tab".
   *   - autoPairs:   A mapping of open/close characters, where the close
   *                  characters are automatically injected when the user enters
   *                  the opening character. For example: `[ "{": "}" ]` would
   *                  automatically insert the closing "}" if the user enters
   *                  "{". If no value is given, the default mapping for the
   *                  language is used.
   *   - inset:       The editor can be inset in the scroll view. Defaults to
   *                  8/8.
   */
  public init(source      : Binding<String>,
              language    : Language?            = nil,
              theme       : ThemeName            = .default,
              fontSize    : Binding<CGFloat>?    = nil,
              flags       : Flags                = .defaultEditorFlags,
              indentStyle : IndentStyle          = .system,
              autoPairs   : [ String : String ]? = nil,
              inset       : CGSize?              = nil)
  {
    self.source      = source
    self.fontSize    = fontSize
    self.language    = language
    self.themeName   = theme
    self.flags       = flags
    self.indentStyle = indentStyle
    self.inset       = inset ?? CGSize(width: 8, height: 8)
    self.autoPairs   = autoPairs
                    ?? language.flatMap({ CodeEditor.defaultAutoPairs[$0] })
                    ?? [:]
  }
  
  /**
   * Configures a read-only CodeEditor View with the given parameters.
   *
   * - Parameters:
   *   - source:      A String that holds the source code to be displayed.
   *   - language:    Optionally set a language (e.g. `.swift`), otherwise
   *                  Highlight.js will attempt to detect the language.
   *   - theme:       The name of the theme to use, defaults to "pojoaque".
   *   - fontSize:    On macOS this Binding can be used to persist the size of
   *                  the font in use. At runtime this is combined with the
   *                  theme to produce the full font information. (optional)
   *   - flags:       Configure whether the text is selectable
   *                  (defaults to both).
   *   - indentStyle: Optionally insert a configurable amount of spaces if the
   *                  user hits "tab".
   *   - autoPairs:   A mapping of open/close characters, where the close
   *                  characters are automatically injected when the user enters
   *                  the opening character. For example: `[ "{": "}" ]` would
   *                  automatically insert the closing "}" if the user enters
   *                  "{". If no value is given, the default mapping for the
   *                  language is used.
   *   - inset:       The editor can be inset in the scroll view. Defaults to
   *                  8/8.
   */
  @inlinable
  public init(source      : String,
              language    : Language?            = nil,
              theme       : ThemeName            = .default,
              fontSize    : Binding<CGFloat>?    = nil,
              flags       : Flags                = .defaultViewerFlags,
              indentStyle : IndentStyle          = .system,
              autoPairs   : [ String : String ]? = nil,
              inset       : CGSize?              = nil)
  {
    assert(!flags.contains(.editable), "Editing requires a Binding")
    self.init(source      : .constant(source),
              language    : language,
              theme       : theme,
              fontSize    : fontSize,
              flags       : flags.subtracting(.editable),
              indentStyle : indentStyle,
              autoPairs   : autoPairs,
              inset       : inset)
  }
  
  private var source      : Binding<String>
  private var fontSize    : Binding<CGFloat>?
  private let language    : Language?
  private let themeName   : ThemeName
  private let flags       : Flags
  private let indentStyle : IndentStyle
  private let autoPairs   : [ String : String ]
  private let inset       : CGSize

  public var body: some View {
    UXCodeTextViewRepresentable(source      : source,
                                language    : language,
                                theme       : themeName,
                                fontSize    : fontSize,
                                flags       : flags,
                                indentStyle : indentStyle,
                                autoPairs   : autoPairs,
                                inset       : inset)
  }
}

struct CodeEditor_Previews: PreviewProvider {
  
  static var previews: some View {
    
    CodeEditor(source: "let a = 5")
      .frame(width: 200, height: 100)
    
    CodeEditor(source: "let a = 5", language: .swift, theme: .pojoaque)
      .frame(width: 200, height: 100)
    
    CodeEditor(source:
      #"""
      The quadratic formula is $-b \pm \sqrt{b^2 - 4ac} \over 2a$
      \bye
      """#, language: .tex
    )
    .frame(width: 540, height: 200)
  }
}
