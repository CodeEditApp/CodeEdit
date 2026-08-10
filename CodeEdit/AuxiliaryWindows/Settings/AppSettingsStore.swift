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

    /// One copy-aside per store, however many sections turn out to be undecodable: the copy is of the
    /// whole file, so the first one already contains every one of them.
    private var hasPreservedOriginal = false

    init(settingsURL: URL = SettingsLocation.settingsFileURL) {
        self.settingsURL = settingsURL
        self.store = Self.loadStore(at: settingsURL)

        // The whole-file copy above only covers a file that failed to *load*. A file that loads fine
        // but holds one section this build cannot decode is the same loss at a smaller scale: the
        // section reads as defaults, and the first write of it replaces the user's JSON with values
        // they never chose. `SettingsStore` announces exactly that moment, before it happens and
        // while the original is still on disk, so the same copy-aside applies.
        self.store.willReplaceUndecodableSection = { [weak self] _ in
            guard let self, !self.hasPreservedOriginal else { return }
            self.hasPreservedOriginal = true
            Self.preserveUnreadableFile(at: settingsURL)
        }

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
    ///
    /// The two failure cases are **not** equivalent and are deliberately handled differently. A file
    /// that is *absent* means a first launch, and an empty store is the correct answer. A file that
    /// is *present but unreadable* means the user has settings that something here failed to parse —
    /// a bug in this code, a half-written file, a manual edit with a stray comma. Answering with an
    /// empty store is still the only way to keep launching, but the first subsequent write would
    /// then persist that emptiness over the original, destroying settings that were very likely
    /// recoverable by hand.
    ///
    /// So the original is copied aside first, and the copy is what makes the fallback survivable.
    /// The alternative considered — refusing to save until the user explicitly re-saves — was
    /// rejected: it turns one silent failure into another (every later change is dropped with no
    /// indication), and it still loses the file the moment anything does write.
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
            preserveUnreadableFile(at: url)
            return SettingsStore()
        }
        return loaded
    }

    /// Copies an unreadable `settings.json` to `settings.json.corrupt-<timestamp>` before anything
    /// can overwrite it.
    ///
    /// Called from two places: a whole file that failed to load, and — via
    /// `SettingsStore.willReplaceUndecodableSection` — the first write that would replace a single
    /// section this build could not decode.
    ///
    /// Copied rather than moved, so the app still finds a file where it expects one, and so a
    /// failure to copy cannot itself destroy the original. `copyItem` is used rather than re-reading
    /// the bytes because the file may have failed to *read*, not merely to parse.
    private static func preserveUnreadableFile(at url: URL) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        // Colon-free: legal on APFS, but a filename with colons reads as a path separator in the
        // Finder and in plenty of shell tooling, and this file exists to be found and inspected.
        formatter.dateFormat = "yyyy-MM-dd'T'HH-mm-ss'Z'"

        let backup = url.appendingPathExtension("corrupt-\(formatter.string(from: Date()))")
        guard !FileManager.default.fileExists(atPath: backup.path) else { return }
        try? FileManager.default.copyItem(at: url, to: backup)
    }

    /// Writes every section — including the ones nothing here decodes — to `settings.json`.
    ///
    /// The write is `.atomic` so an interrupted save cannot leave a truncated file where the user's
    /// settings used to be.
    private func save() throws {
        try store.encoded().write(to: settingsURL, options: .atomic)
    }
}
