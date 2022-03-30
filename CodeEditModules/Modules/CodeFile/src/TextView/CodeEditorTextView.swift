//
//  CodeEditorTextView.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 19/03/22.
//

import Cocoa
import SwiftUI

public class CodeEditorTextView: NSTextView {
    @AppStorage(EditorTabWidth.storageKey)
    private var tabWidth: Int = EditorTabWidth.default

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
    ]

    public override func insertText(_ string: Any, replacementRange: NSRange) {
        super.insertText(string, replacementRange: replacementRange)
        guard let string = string as? String,
              let end = autoPairs[string]
        else { return }
        super.insertText(end, replacementRange: selectedRange())
        super.moveBackward(self)
    }

    public override func insertTab(_ sender: Any?) {
        super.insertText(
            String(
                repeating: " ",
                count: tabWidth
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
    public override func menu(for event: NSEvent) -> NSMenu? {
        guard var menu = super.menu(for: event) else { return nil }

        menu = helpMenu(menu)
        menu = codeMenu(menu)
        menu = gitMenu(menu)
        menu = removeSubMenus(menu)
        menu = removeTextMenu(menu)

        return menu
    }

    func helpMenu(_ menu: NSMenu) -> NSMenu {
        menu.insertItem(withTitle: "Jump To Definition",
                        action: nil,
                        keyEquivalent: "",
                        at: 1)

        menu.insertItem(withTitle: "Show Code Actions",
                        action: nil,
                        keyEquivalent: "",
                        at: 2)

        menu.insertItem(withTitle: "Show Quick Help",
                        action: nil,
                        keyEquivalent: "",
                        at: 3)

        menu.insertItem(.separator(), at: 4)

        return menu
    }

    func codeMenu(_ menu: NSMenu) -> NSMenu {

        menu.insertItem(withTitle: "Refactor",
                        action: nil,
                        keyEquivalent: "",
                        at: 5)

        menu.insertItem(withTitle: "Find",
                        action: nil,
                        keyEquivalent: "",
                        at: 6)

        menu.insertItem(withTitle: "Navigate",
                        action: nil,
                        keyEquivalent: "",
                        at: 7)

        menu.insertItem(.separator(), at: 8)

        return menu
    }

    func gitMenu(_ menu: NSMenu) -> NSMenu {
        menu.insertItem(withTitle: "Show Last Change For Line",
                        action: nil,
                        keyEquivalent: "",
                        at: 9)

        menu.insertItem(withTitle: "Create Code Snippet...",
                        action: nil,
                        keyEquivalent: "",
                        at: 10)

        menu.insertItem(withTitle: "Add Pull Request Discussion to Current Line",
                        action: nil,
                        keyEquivalent: "",
                        at: 11)

        menu.insertItem(.separator(), at: 12)

        return menu
    }

    func removeSubMenus(_ menu: NSMenu) -> NSMenu {
        // remove unwanted "Font" menu and its submenus

        if let substitutionsItem = menu.item(withTitle: "Substitutions") {
            menu.removeItem(substitutionsItem)
        }

        if let transformationsItem = menu.item(withTitle: "Transformations") {
            menu.removeItem(transformationsItem)
        }

        if let speechItem = menu.item(withTitle: "Speech") {
            menu.removeItem(speechItem)
        }

        if let shareItem = menu.item(withTitle: "Share") {
            menu.removeItem(shareItem)
        }

        if let searchGoogleItem = menu.item(withTitle: "Search With Google") {
            menu.removeItem(searchGoogleItem)
        }

        if let fontMenuItem = menu.item(withTitle: "Font") {
            menu.removeItem(fontMenuItem)
        }

        return menu
    }

    func removeTextMenu(_ menu: NSMenu) -> NSMenu {

        if let guessesItem = menu.item(withTitle: "No Guesses Found") {
            menu.removeItem(guessesItem)
        }

        if let ignoreItem = menu.item(withTitle: "Ignore Spelling") {
            menu.removeItem(ignoreItem)
        }

        if let learnItem = menu.item(withTitle: "Learn Spelling") {
            menu.removeItem(learnItem)
        }

        if let lookUpItem = menu.item(withTitle: "Look Up") {
            menu.removeItem(lookUpItem)
        }

        if let searchGoogleItem = menu.item(withTitle: "Search With Google") {
            menu.removeItem(searchGoogleItem)
        }

        if let translateItem = menu.item(withTitle: "Translate") {
            menu.removeItem(translateItem)
        }

        if let spellingGrammarItem = menu.item(withTitle: "Spelling and Grammar") {
            menu.removeItem(spellingGrammarItem)
        }

        return menu
    }

}
