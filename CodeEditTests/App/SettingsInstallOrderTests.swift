//
//  SettingsInstallOrderTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 10/08/2026.
//

import Testing
import CodeEditSettings
@testable import CodeEdit

/// Guards the *consequence* of the settings store reaching `ThemeModel` too late.
///
/// `ThemeModel.shared` is configured from `AppDependencies.init`, which runs while `AppDelegate`'s
/// non-lazy `dependencies` property is initialized — before any delegate callback. It previously ran
/// in `applicationDidFinishLaunching`, which `application(_:open urls:)` can beat: opening a folder
/// from Finder at cold start builds a workspace window first, and `CodeEditWindowController`
/// force-unwraps `ThemeModel.shared.themes.first!`. On an unconfigured model that array is empty and
/// the app crashes in release.
///
/// **What this proves and does not.** The ordering itself is structural — it holds because
/// `dependencies` is a stored `let`, not because of anything asserted here — and this test cannot
/// distinguish it from the old ordering, since the app host has fully launched by the time any test
/// runs. What it does guard is the invariant that made the misordering fatal rather than merely
/// wrong: that by the time anything can open a window, the themes are loaded and that force-unwrap
/// is safe. A future change that leaves `ThemeModel` unconfigured at window-open time fails here
/// instead of in a user's crash log.
@MainActor
struct SettingsInstallOrderTests {

    @Test
    func themesAreLoadedBeforeAnyWindowCanOpen() {
        #expect(
            !ThemeModel.shared.themes.isEmpty,
            "CodeEditWindowController force-unwraps ThemeModel.shared.themes.first!"
        )
    }

    /// The model reads through a real store, not `DefaultSettingsReader`.
    ///
    /// Asserted through behaviour rather than by inspecting the accessor: a configured model has
    /// resolved a selected theme from the store, which a defaults-only reader cannot produce
    /// alongside a loaded theme list.
    @Test
    func themeModelResolvedASelectionFromTheStore() {
        #expect(ThemeModel.shared.selectedTheme != nil)
    }
}
