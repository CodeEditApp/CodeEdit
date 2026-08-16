//
//  ActiveThemeTests.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 15/08/26.
//

import Combine
import Testing
@testable import CodeEditCore

@MainActor
struct ActiveThemeTests {

    /// A change must reach observers — this is the whole reason the type exists.
    ///
    /// The count is asserted as "at least one": `update` assigns both `@Published` properties
    /// unconditionally, so one call emits twice. Only *reaching* observers is the contract.
    @Test
    func publishesWhenTheCurrentThemeChanges() {
        let active = ActiveTheme()
        var emissions = 0
        let token = active.objectWillChange.sink { _ in emissions += 1 }

        active.update(current: Self.makeTheme(name: "Solarized"), dark: nil)

        #expect(emissions >= 1)
        #expect(active.current?.name == "Solarized")
        token.cancel()
    }

    /// Editing a colour of the *active* theme must reach observers, and must be stored.
    ///
    /// ``Theme`` is `Equatable` by name, so an edited copy of the active theme compares *equal* to
    /// it. An equality guard in `update` therefore dropped this write entirely: the editor and the
    /// terminal kept rendering the old colours while the settings preview showed the new ones.
    @Test
    func publishesAndStoresAThemeEditedUnderTheSameName() {
        let original = Self.makeTheme(name: "Solarized", editorText: "#000000")
        let edited = Self.makeTheme(name: "Solarized", editorText: "#FF00FF")
        let active = ActiveTheme()
        active.update(current: original, dark: nil)

        var emissions = 0
        let token = active.objectWillChange.sink { _ in emissions += 1 }

        active.update(current: edited, dark: nil)

        #expect(original == edited, "Precondition: Theme equality is by name, not by value.")
        #expect(emissions >= 1)
        #expect(active.current?.editor.text.color == "#FF00FF")
        token.cancel()
    }

    // MARK: - Fixture

    private static func attr() -> Theme.Attributes {
        Theme.Attributes(color: "#000000")
    }

    private static func makeTheme(name: String, editorText: String = "#000000") -> Theme {
        let editor = Theme.EditorColors(
            text: Theme.Attributes(color: editorText),
            insertionPoint: attr(), invisibles: attr(), background: attr(),
            lineHighlight: attr(), selection: attr(), keywords: attr(), commands: attr(),
            types: attr(), attributes: attr(), variables: attr(), values: attr(),
            numbers: attr(), strings: attr(), characters: attr(), comments: attr()
        )
        let terminal = Theme.TerminalColors(
            text: attr(), boldText: attr(), cursor: attr(), background: attr(), selection: attr(),
            black: attr(), red: attr(), green: attr(), yellow: attr(), blue: attr(), magenta: attr(),
            cyan: attr(), white: attr(), brightBlack: attr(), brightRed: attr(), brightGreen: attr(),
            brightYellow: attr(), brightBlue: attr(), brightMagenta: attr(), brightCyan: attr(),
            brightWhite: attr()
        )
        return Theme(
            editor: editor,
            terminal: terminal,
            author: "Test",
            license: "MIT",
            metadataDescription: "Test theme",
            distributionURL: "",
            isBundled: false,
            name: name,
            displayName: name,
            appearance: .dark,
            version: "1.0"
        )
    }
}
