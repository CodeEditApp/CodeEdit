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
    @Test
    func publishesWhenTheCurrentThemeChanges() {
        let active = ActiveTheme()
        var emissions = 0
        let token = active.objectWillChange.sink { _ in emissions += 1 }

        active.update(current: Self.makeTheme(name: "Solarized"), dark: nil)

        #expect(emissions == 1)
        #expect(active.current?.name == "Solarized")
        token.cancel()
    }

    /// Assigning an equal value must NOT publish. `@Published` fires on every set regardless of
    /// equality, and both observers are expensive views — without this guard, any repeated write
    /// re-renders the editor and the terminal for nothing.
    @Test
    func doesNotPublishWhenAssignedAnEqualValue() {
        let theme = Self.makeTheme(name: "Solarized")
        let active = ActiveTheme()
        active.update(current: theme, dark: nil)

        var emissions = 0
        let token = active.objectWillChange.sink { _ in emissions += 1 }

        active.update(current: theme, dark: nil)

        #expect(emissions == 0)
        token.cancel()
    }

    /// A fresh holder is already `nil`; setting `nil` again must be a no-op too.
    @Test
    func doesNotPublishWhenSettingNilOnAFreshHolder() {
        let active = ActiveTheme()
        var emissions = 0
        let token = active.objectWillChange.sink { _ in emissions += 1 }

        active.update(current: nil, dark: nil)

        #expect(emissions == 0)
        token.cancel()
    }

    // MARK: - Fixture

    private static func attr() -> Theme.Attributes {
        Theme.Attributes(color: "#000000")
    }

    private static func makeTheme(name: String) -> Theme {
        let editor = Theme.EditorColors(
            text: attr(), insertionPoint: attr(), invisibles: attr(), background: attr(),
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
