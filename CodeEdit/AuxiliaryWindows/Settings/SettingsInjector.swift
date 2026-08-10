//
//  SettingsInjector.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 28/04/2023.
//

import SwiftUI
import CodeEditSettings

/// Supplies the settings seam to a view subtree, and re-renders it when settings change.
///
/// Wrap every **standalone** `NSHostingView`/`NSHostingController` root in this: `@Environment` does
/// not cross a hosting boundary, so a root that skips it hands its whole subtree
/// `DefaultSettingsReader` — plausible defaults for reads, silently discarded writes.
struct SettingsInjector<Content: View>: View {

    /// Observed, not merely held: this view's job is to re-inject `revision` when it changes.
    @ObservedObject var store: AppSettingsStore

    @ViewBuilder var content: Content

    init(store: AppSettingsStore, @ViewBuilder content: () -> Content) {
        self.store = store
        self.content = content()
    }

    var body: some View {
        content
            .environment(\.settingsAccessor, store)
            // The seam's invalidation signal. Rewriting the accessor above is *not* enough: it is a
            // stable instance behind an existential, so whether SwiftUI treats the rewrite as a
            // change is unspecified — and `.appServices(_:)`, applied closer to the leaf in
            // `CodeEditSplitViewController`, overwrites it with the same instance anyway.
            // `settingsRevision` is `Equatable` and lives in its own key, so neither can defeat it.
            .environment(\.settingsRevision, store.revision)
    }
}

/// The scene-level counterpart of ``SettingsInjector``.
///
/// The app's scenes are not inside any hosting root, so they need their own injector — and it must
/// be a `Scene`, since a `View` cannot wrap one. `CodeEditApp` can *reach* the store (it does, in
/// `init`, through the `NSApplicationDelegateAdaptor`), but it cannot `@ObservedObject` it: the
/// store is not one of its stored properties, and a property wrapper cannot be attached to a value
/// obtained from another one. So the observation lives here instead.
///
/// Note what this does **not** cover: `.commands { }` is attached beside a scene's content, not
/// inside it, so these `.environment` values are not documented to reach `Commands` conformers.
/// `CodeEditCommands` therefore takes the store by initializer — see its documentation.
struct SettingsSceneInjector<Content: Scene>: Scene {

    /// Observed, not merely held: this scene's job is to re-inject `revision` when it changes.
    @ObservedObject var store: AppSettingsStore

    var content: Content

    init(store: AppSettingsStore, @SceneBuilder content: () -> Content) {
        self.store = store
        self.content = content()
    }

    var body: some Scene {
        content
            .environment(\.settingsAccessor, store)
            .environment(\.settingsRevision, store.revision)
    }
}
