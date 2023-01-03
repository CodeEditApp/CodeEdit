//
//  StoreCategories.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/01/2023.
//

import SwiftUI

enum StoreCategories: Identifiable, CaseIterable, CustomStringConvertible {
    case suggestions,
         new,
         languages,
         snippets,
         sidebars,
         actions,
         editor,
         formatters,
         themes

    var id: Self { self }

    var description: String {
        switch self {
        case .suggestions:
            return "Suggestions"
        case .new:
            return "New"
        case .languages:
            return "Languages"
        case .snippets:
            return "Snippets"
        case .sidebars:
            return "Sidebars"
        case .actions:
            return "Actions"
        case .editor:
            return "Editor"
        case .formatters:
            return "Formatters"
        case .themes:
            return "Themes"
        }
    }

    var icon: String {
        switch self {

        case .suggestions:
            return "wand.and.stars"
        case .new:
            return "star"
        case .languages:
            return "swift"
        case .snippets:
            return "chevron.left.forwardslash.chevron.right"
        case .sidebars:
            return "sidebar.leading"
        case .actions:
            return "arrow.triangle.branch"
        case .editor:
            return "text.and.command.macwindow"
        case .formatters:
            return "text.word.spacing"
        case .themes:
            return "atom"
        }
    }
}
