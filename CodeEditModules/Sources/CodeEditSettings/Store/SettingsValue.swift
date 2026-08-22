//
//  SettingsValue.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 09/08/26.
//

import Foundation
import SwiftUI

/// Read access to settings, one section at a time.
///
/// Feature packages depend on this rather than on the concrete store, so they never name the
/// app-wide aggregate and never reach a singleton.
///
/// This is the seam for **non-SwiftUI** consumers — models, services, AppKit controllers — which take
/// it by initializer. SwiftUI views observe ``PersistentSettingsStore`` directly through
/// ``SettingsValue`` instead, because `@EnvironmentObject` cannot carry a protocol existential.
///
/// Deliberately neither `Sendable` nor `@MainActor`: conforming types include a store class whose
/// methods cannot be actor-isolated without breaking this conformance. The other former reason —
/// that `EnvironmentKey` requires a nonisolated static default — no longer applies, since that key
/// is gone. What still blocks isolation is the Swift 5 app target, where annotating this protocol
/// cascades into its callers.
public protocol SettingsReading {
    /// The current value of `type`, or its defaults if the section is absent.
    func value<S: SettingsSection>(_ type: S.Type) -> S
}

/// A reader that answers with defaults and **discards every write**, trapping in debug.
///
/// This was the environment key's fallback. That key is gone — a view with no store now traps
/// immediately — but the type survives for its *other* role: the stand-in that pre-existing
/// singletons (`ThemeModel`, `FeedbackModel`, `SearchSettingsModel`, `HistoryInspectorModel`) hold
/// between construction and `configure(_:)`. Being used at all still means a wiring bug, so both
/// methods `assertionFailure` unless `XCODE_RUNNING_FOR_PREVIEWS` is set.
///
/// The discarding write is the dangerous half: a consumer that never received a real store reads
/// plausible defaults and *appears* to save, losing the user's change with no error.
public struct DefaultSettingsReader: SettingsAccessing {
    /// Previews legitimately render with no store configured; everywhere else, reaching this type
    /// is a wiring bug worth a debug trap.
    private static var isRunningInPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    public init() {}

    /// Answers with defaults. Reads are only *misleading*, not destructive, so they trap in debug
    /// but the value is still returned — a preview or a mis-wired consumer keeps working.
    public func value<S: SettingsSection>(_ type: S.Type) -> S {
        if !Self.isRunningInPreviews {
            assertionFailure(
                "Read of '\(S.settingsKey)' fell back to defaults: this consumer never received a "
                + "settings store. Singletons receive one through `configure(_:)` at launch."
            )
        }
        return S()
    }

    /// Discards `value`. See the type's documentation — this is a no-op, not a save.
    public func setValue<S: SettingsSection>(_ value: S) {
        if !Self.isRunningInPreviews {
            assertionFailure(
                "Write to '\(S.settingsKey)' was discarded: this consumer never received a settings "
                + "store. Singletons receive one through `configure(_:)` at launch."
            )
        }
    }
}

/// A fixed reader for tests and SwiftUI previews.
public struct SnapshotSettingsReader: SettingsReading {
    private let sections: [String: any SettingsSection]

    public init(_ sections: [String: any SettingsSection]) {
        self.sections = sections
    }

    public func value<S: SettingsSection>(_ type: S.Type) -> S {
        sections[S.settingsKey] as? S ?? S()
    }
}

/// Reads and writes one property of one settings section inside a SwiftUI view.
///
/// ```swift
/// @SettingsValue(TerminalSettings.self, \.cursorBlink) private var cursorBlink
/// @SettingsValue(TextEditingSettings.self, \.showMinimap) private var showMinimap
/// Toggle("Show Minimap", isOn: $showMinimap)
/// ```
///
/// Only valid inside a `View`. AppKit types must be handed the value by their
/// `NSViewRepresentable` instead — read at the SwiftUI boundary, pass by value inward.
///
/// The key path is a `WritableKeyPath` even for read-only uses: every settings field is a `var`, so
/// requiring it costs read-only call sites nothing and keeps one property wrapper for both jobs.
///
/// **A missing injection traps.** This replaced a pair of environment *keys* — one for the value,
/// one for an `Int` invalidation signal — whose failure modes were both silent: a subtree given
/// neither read plausible defaults and discarded writes, and a subtree given the value but not the
/// signal read correctly and never re-rendered. `@EnvironmentObject` makes both unrepresentable.
/// SwiftUI subscribes to the object itself, so there is no second key to forget and nothing to keep
/// in sync.
///
/// **Main-actor isolated deliberately, and it must stay that way.**
///
/// `EnvironmentObject`'s initialiser and wrapped value are `@MainActor` in the SDK, so a
/// nonisolated wrapper touching them fails under Swift 6 strict concurrency. Newer SwiftUI carries
/// `@preconcurrency` annotations that hide this, which is why it compiled on Xcode 26 and failed on
/// the CI runner's Xcode 16.4. The isolation is also true on the merits: this is documented as valid
/// only inside a `View`, and `PersistentSettingsStore.setValue` already asserts the main thread.
/// Same shape as SwiftUI's own `@StateObject` and `@ObservedObject`.
@propertyWrapper
@MainActor
public struct SettingsValue<S: SettingsSection, Value>: DynamicProperty {
    @EnvironmentObject private var store: PersistentSettingsStore

    private let keyPath: WritableKeyPath<S, Value>

    public init(_ section: S.Type, _ keyPath: WritableKeyPath<S, Value>) {
        self._store = EnvironmentObject()
        self.keyPath = keyPath
    }

    public var wrappedValue: Value {
        get { store.value(S.self)[keyPath: keyPath] }
        // Read-modify-write of the whole section: the store is section-granular, and this is the
        // only way to change one field without naming the settings aggregate.
        nonmutating set {
            var section = store.value(S.self)
            section[keyPath: keyPath] = newValue
            store.setValue(section)
        }
    }

    /// A binding to the setting, for controls like `Toggle` and `TextField`.
    public var projectedValue: Binding<Value> {
        Binding {
            wrappedValue
        } set: {
            wrappedValue = $0
        }
    }
}
