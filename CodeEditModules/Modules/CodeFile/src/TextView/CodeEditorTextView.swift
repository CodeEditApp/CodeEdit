//
//  CodeEditorTextView.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 19/03/22.
//

import Cocoa
import SwiftUI
import AppPreferences

public final class CodeEditorTextView: NSTextView {

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    init(
        textContainer container: NSTextContainer?
    ) {
        super.init(frame: .zero, textContainer: container)
        drawsBackground = true
        isEditable = true
        isHorizontallyResizable = false
        isVerticallyResizable = true
        allowsUndo = true
        isRichText = false
        isGrammarCheckingEnabled = false
        isContinuousSpellCheckingEnabled = false
        isAutomaticQuoteSubstitutionEnabled = false
        isAutomaticDashSubstitutionEnabled = false
        isIncrementalSearchingEnabled = true
        usesFindBar = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private var swiftSelectedRange: Range<String.Index> {
        let string = self.string
        guard !string.isEmpty else { return string.startIndex..<string.startIndex }
        guard let selectedRange = Range(self.selectedRange(), in: string) else {
            assertionFailure("Could not convert the selectedRange")
            return string.startIndex..<string.startIndex
        }
        return selectedRange
    }
    private var currentLine: String {
        let string = self.string
        return String(string[string.lineRange(for: swiftSelectedRange)])
    }

    public override func insertNewline(_ sender: Any?) {
        // get line before newline
        let currentLine = self.currentLine
        let prefix = currentLine.prefix {
            guard let scalar = $0.unicodeScalars.first else {
                return false
            }

            return CharacterSet.whitespaces.contains(scalar)
        }

        super.insertNewline(sender)

        if !prefix.isEmpty {
            insertText(String(prefix), replacementRange: selectedRange())
        }
    }

    let autoPairs = [
        "(": ")",
        "{": "}",
        "[": "]",
        "\"": "\"",
        "\'": "\'"
    ]

    /// Autocompletes if symbol is auto pair
    private func autocompleteSymbols(_ symbol: String) {
        guard let end = autoPairs[symbol]
        else { return }

        if prefs.preferences.textEditing.autocompleteBraces && symbol == "{" {
            super.insertText(end, replacementRange: selectedRange())
            super.moveBackward(self)
            return
        }

        guard prefs.preferences.textEditing.enableTypeOverCompletion, symbol != "{"
        else { return }

        super.insertText(end, replacementRange: selectedRange())
        super.moveBackward(self)
    }

    public override func insertText(_ string: Any, replacementRange: NSRange) {
        super.insertText(string, replacementRange: replacementRange)
        guard let string = string as? String
        else { return }
        self.autocompleteSymbols(string)
    }

    public override func insertTab(_ sender: Any?) {
        super.insertText(
            String(
                repeating: " ",
                count: prefs.preferences.textEditing.defaultTabWidth
            ),
            replacementRange: selectedRange()
        )
    }

    /// input a backslash (\\)
    @IBAction func inputBackSlash(_ sender: Any?) {
        super.insertText(
            "\\",
            replacementRange: selectedRange()
        )
    }

    /// Override of the default context menu in the editor...
    ///
    /// This is a basic view without any functionality, once we have most the items built
    /// we will start connecting the menu items to their respective actions.
    public override func menu(for event: NSEvent) -> NSMenu? {
        guard var menu = super.menu(for: event) else { return nil }

        menu = helpMenu(menu)
        menu = codeMenu(menu)
        menu = gitMenu(menu)
        menu = removeMenus(menu)

        return menu
    }

    func helpMenu(_ menu: NSMenu) -> NSMenu {
        menu.insertItem(withTitle: "Jump To Definition",
                        action: nil,
                        keyEquivalent: "",
                        at: 0)

        menu.insertItem(withTitle: "Show Code Actions",
                        action: nil,
                        keyEquivalent: "",
                        at: 1)

        menu.insertItem(withTitle: "Show Quick Help",
                        action: nil,
                        keyEquivalent: "",
                        at: 2)

        menu.insertItem(.separator(), at: 3)

        return menu
    }

    func codeMenu(_ menu: NSMenu) -> NSMenu {

        menu.insertItem(withTitle: "Refactor",
                        action: nil,
                        keyEquivalent: "",
                        at: 4)

        menu.insertItem(withTitle: "Find",
                        action: nil,
                        keyEquivalent: "",
                        at: 5)

        menu.insertItem(withTitle: "Navigate",
                        action: nil,
                        keyEquivalent: "",
                        at: 6)

        menu.insertItem(.separator(), at: 7)

        return menu
    }

    func gitMenu(_ menu: NSMenu) -> NSMenu {
        menu.insertItem(withTitle: "Show Last Change For Line",
                        action: nil,
                        keyEquivalent: "",
                        at: 8)

        menu.insertItem(withTitle: "Create Code Snippet...",
                        action: nil,
                        keyEquivalent: "",
                        at: 9)

        menu.insertItem(withTitle: "Add Pull Request Discussion to Current Line",
                        action: nil,
                        keyEquivalent: "",
                        at: 10)

        menu.insertItem(.separator(), at: 11)

        return menu
    }

    /// This removes the default menu items in the context menu based on their name..
    ///
    /// The only problem currently is how well it would work with other languages.
    func removeMenus(_ menu: NSMenu) -> NSMenu {
        let removeItemsContaining = [
            // Learn Spelling
            "_learnSpellingFromMenu:",

            // Ignore Spelling
            "_ignoreSpellingFromMenu:",

            // Spelling suggestion
            "_changeSpellingFromMenu:",

            // Search with Google
            "_searchWithGoogleFromMenu:",

            // Share, Font, Spelling and Grammar, Substitutions, Transformations
            // Speech, Layout Orientation
            "submenuAction:",

            // Lookup, Translate
            "_rvMenuItemAction"
        ]

        for item in menu.items {
            if let itemAction = item.action {
                if removeItemsContaining.contains(String(describing: itemAction)) {
                    // Get localized item name, and remove it.
                    let index = menu.indexOfItem(withTitle: item.title)
                    if index >= 0 {
                        menu.removeItem(at: index)
                    }
                }
            }
        }

        return menu
    }
}
