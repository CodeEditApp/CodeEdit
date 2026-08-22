//
//  ActiveTheme.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 15/08/26.
//

import Combine

/// The themes currently in effect, published to whatever is rendering with them.
///
/// **Holds only the themes in effect — keep it that way.** An `ObservableObject` invalidates every
/// observer on any published change, and the observers here are the code editor and the terminal.
/// Adding frequently-changing state would re-render both for changes they do not care about.
/// Theme *management* — the list, selection UI, add/edit state — stays in the app-side `ThemeModel`.
///
/// Lives in `CodeEditCore` because `ObservableObject` is Combine, not SwiftUI: Core's charter forbids
/// only `SwiftUI`, `AppKit` and `Cocoa`. `FindReplaceQuery` is the existing precedent.
public final class ActiveTheme: ObservableObject {

    /// The theme in effect, or `nil` before any theme has loaded.
    @Published public private(set) var current: Theme?

    /// The theme to use where a dark appearance is forced independently of `current` — the terminal
    /// does this when its own `darkAppearance` setting is on.
    @Published public private(set) var dark: Theme?

    public init() {}

    /// Assigns unconditionally, publishing on every call.
    ///
    /// **Do not reinstate an equality guard here.** One was tried and removed: ``Theme`` is
    /// `Equatable` by *name* (`Theme.==` compares `id`, which is `name`), because
    /// `themes.firstIndex(of:)` relies on that to find a theme to update in place. A `!=` guard
    /// therefore reads "same theme" for an edited copy of the active theme and silently swallows
    /// colour changes, leaving this holder on a stale struct forever. Writes are human-scale — a
    /// theme switch or a colour edit — so the redundant publishes cost nothing worth guarding.
    public func update(current: Theme?, dark: Theme?) {
        self.current = current
        self.dark = dark
    }
}
