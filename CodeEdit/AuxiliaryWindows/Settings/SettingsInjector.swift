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
    @ObservedObject var store: PersistentSettingsStore

    @ViewBuilder var content: Content

    init(store: PersistentSettingsStore, @ViewBuilder content: () -> Content) {
        self.store = store
        self.content = content()
    }

    var body: some View {
        content
            // One injection carries both the value and the change signal. SwiftUI subscribes to
            // the object itself, which is what the retired pair of environment keys — an accessor
            // plus an `Int` revision — needed two keys and a hand-maintained counter to express.
            .environmentObject(store)
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
    @ObservedObject var store: PersistentSettingsStore

    var content: Content

    init(store: PersistentSettingsStore, @SceneBuilder content: () -> Content) {
        self.store = store
        self.content = content()
    }

    var body: some Scene {
        content
            .environmentObject(store)
    }
}
