//
//  AppSettingsStore.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 10/08/26.
//

import Combine
import Foundation
import CodeEditSettings

/// The app's single settings store: owns the on-disk state, the save pipeline and the seam's
/// invalidation signal.
///
/// Constructed and owned by `AppDependencies`, the app-scope composition root — this type has no
/// `shared`. It replaces `Settings.shared`, which reached the same state from anywhere and could
/// therefore never be substituted in a test or a second configuration.
///
/// Not `@MainActor`: it conforms to ``SettingsAccessing``, which is deliberately nonisolated so it
/// can be an `EnvironmentKey` value (see that protocol's documentation). Main-thread use is asserted
/// at the write entry point instead.
final class AppSettingsStore: ObservableObject, SettingsAccessing {

    /// Section-keyed storage. Sections nothing here decodes are held verbatim and re-emitted on
    /// save, so a disabled extension's configuration survives.
    private let store: SettingsStore

    /// One element per write. Throttled rather than debounced so a continuous stream of changes
    /// (dragging a font-size slider) still reaches disk at a bounded interval instead of only when
    /// the user stops.
    private let saveRequests = PassthroughSubject<Void, Never>()

    private var saveTask: AnyCancellable?

    /// A counter incremented once per change to any section.
    ///
    /// This is the settings seam's **invalidation signal**. Views reach settings through
    /// ``SettingsValue`` or `AppSettings`, whose only other environment dependency is
    /// ``EnvironmentValues/settingsAccessor`` — an existential holding a store that never compares
    /// unequal to itself. Re-rendering on a settings change would then rest on SwiftUI treating a
    /// rewritten non-`Equatable` existential as a change, which is unspecified. An `Int` is
    /// `Equatable`, so an injector publishing it into ``EnvironmentValues/settingsRevision`` makes
    /// the invalidation explicit and precise.
    @Published private(set) var revision: Int = 0

    /// `~/Library/Application Support/CodeEdit/` — the folder settings and adjacent app data live in.
    var baseURL: URL { SettingsLocation.baseURL }

    /// The file this store loads from and saves to. Injectable so a test can point a store at a
    /// temporary file instead of the user's real `settings.json`.
    private let settingsURL: URL

    init(settingsURL: URL = SettingsLocation.settingsFileURL) {
        self.settingsURL = settingsURL
        self.store = Self.loadStore(at: settingsURL)

        self.saveTask = saveRequests
            .throttle(for: 2, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                try? self?.save()
            }
    }

    // MARK: - SettingsAccessing

    func value<S: SettingsSection>(_ type: S.Type) -> S {
        store[S.self]
    }

    func setValue<S: SettingsSection>(_ value: S) {
        // `SettingsAccessing` is deliberately nonisolated (see the protocol's docs), so the compiler
        // cannot enforce this. A write bumps `revision`, whose `@Published` change drives AppKit
        // through SwiftUI observers — off the main thread that corrupts AppKit state rather than
        // failing cleanly. Loud in debug, unchanged in release.
        MainActor.assertIsolated("Settings must be written on the main thread")

        store[S.self] = value
        // Mutate first, then publish: a view body re-evaluated by this revision change already reads
        // the new value. `Settings` achieved the same ordering by bumping on `$preferences`'
        // `willSet`; doing it explicitly after the store write makes the guarantee local instead of
        // dependent on Combine's emission timing.
        revision &+= 1
        saveRequests.send()
    }

    // MARK: - Persistence

    /// Builds the store from `settings.json`, or an empty one when the file is absent or unreadable.
    private static func loadStore(at url: URL) -> SettingsStore {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: url.path) else {
            try? fileManager.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: false
            )
            return SettingsStore()
        }

        guard let json = try? Data(contentsOf: url),
              let loaded = try? SettingsStore(data: json)
        else {
            return SettingsStore()
        }
        return loaded
    }

    /// Writes every section — including the ones nothing here decodes — to `settings.json`.
    ///
    /// The write is `.atomic` so an interrupted save cannot leave a truncated file where the user's
    /// settings used to be.
    private func save() throws {
        try store.encoded().write(to: settingsURL, options: .atomic)
    }
}
