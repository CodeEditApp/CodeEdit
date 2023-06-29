//
//  ModelNameToSettingName.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 24/06/23.
//

import Foundation
import AppKit

struct ModelNameToSettingName {
    // TODO: Use a string catalog when deployment target is raised to Sonoma 14.0
    // https://developer.apple.com/wwdc23/10155

    let translator: [String: String] = [
        // MARK: - General Settings
        "appAppearance": NSLocalizedString("Appearance", comment: ""),
        "fileIconStyle": NSLocalizedString("File Icon Style", comment: ""),
        "tabBarStyle": NSLocalizedString("Tab Bar Style", comment: ""),
        "navigatorTabBarPosition": NSLocalizedString("Navigator Tab Bar Position", comment: ""),
        "inspectorTabBarPosition": NSLocalizedString("Inspector Tab Bar Position", comment: ""),
        "showIssues": NSLocalizedString("Show Issues", comment: ""),
        "showLiveIssues": NSLocalizedString("Show Live Issues", comment: ""),
        "isAutoSaveOn": NSLocalizedString("Automatically save changes to disk", comment: ""),
        "revealFileOnFocusChange": NSLocalizedString("Automatically reveal in project navigator", comment: ""),
        "reopenBehavior": NSLocalizedString(
            "Reopen Behavior",
            comment: "British English's version of Behavior is Behaviour"
        ),
        "reopenWindowAfterClose": NSLocalizedString("After the last window is closed", comment: ""),
        "hiddenFileExtensions": NSLocalizedString("File Extensions", comment: ""),
        "projectNavigatorSize": NSLocalizedString("Project Navigator Size", comment: ""),
        "findNavigatorDetail": NSLocalizedString("Find Navigator Detail", comment: ""),
        "issueNavigatorDetail": NSLocalizedString("Issue Navigator Detail", comment: ""),
        // MARK: - Accounts Settings
        "sourceControlAccounts": NSLocalizedString("Source Control Accounts", comment: ""),
        // MARK: - Text Editing Settings
        "matchAppearance": NSLocalizedString("Automatically change theme based on system appearance", comment: ""),
        "useThemeBackground": NSLocalizedString("Use theme background", comment: ""),
        "indentOption": NSLocalizedString("Prefer Indent Using", comment: ""),
        "defaultTabWidth": NSLocalizedString("Tab Width", comment: ""),
        "wrapLinesToEditorWidth": NSLocalizedString("Wrap lines to editor width", comment: ""),
        "lineHeightMultiple": NSLocalizedString("Line Height", comment: ""),
        "letterSpacing": NSLocalizedString("Letter Spacing", comment: ""),
        "autocompleteBraces": NSLocalizedString("Autocomplete braces", comment: ""),
        "enableTypeOverCompletion": NSLocalizedString("Enable type-over completion", comment: ""),
        "bracketHighlight": NSLocalizedString("Bracket Pair Highlight", comment: ""),
        // MARK: - Terminal Settings
        "shell": NSLocalizedString(
            "Shell",
            comment: "Wouldn't really make sense to translate this as it might be difficult to understand"
        ),
        "optionAsMeta": NSLocalizedString("Use \"Option\" key as \"Meta\"", comment: ""),
        "useTextEditorFont": NSLocalizedString("Use text editor font", comment: ""),
        "font": NSLocalizedString("Font", comment: ""),
        "cursorStyle": NSLocalizedString("Terminal Cursor Style", comment: ""),
        "cursorBlink": NSLocalizedString("Blink Cursor", comment: ""),
        // MARK: - Source Control Settings
        "general": NSLocalizedString("General", comment: ""),
        "git": NSLocalizedString("Git", comment: ""),
        // MARK: - Locations Settings
        "settingsURL": NSLocalizedString("Settings Location", comment: ""),
        "themesURL": NSLocalizedString("Themes Location", comment: ""),
        "extensionsURL": NSLocalizedString("Extensions Location", comment: ""),
        // MARK: - Feature Flags
        "useNewWindowingSystem": NSLocalizedString("New Windowing System", comment: "")
    ]

    func translate(_ modelName: String) -> String {
        if translator[modelName] != nil {
            return translator[modelName]!
        } else {
            fatalError("""
Please add the new setting to the above translator array, and add it correctly as mentioned in the docs.
""")
        }
    }

    init() {}
}
