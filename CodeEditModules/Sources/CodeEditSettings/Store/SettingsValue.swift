//
//  SettingsValue.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 09/08/26.
//

import SwiftUI

/// Read access to settings, one section at a time.
///
/// Feature packages depend on this rather than on the concrete store, so they never name the
/// app-wide aggregate and never reach a singleton.
///
/// Deliberately neither `Sendable` nor `@MainActor`: conforming types include a store class whose
/// methods cannot be actor-isolated without breaking this conformance, and `EnvironmentKey`
/// requires a nonisolated static default.
public protocol SettingsReading {
    /// The current value of `type`, or its defaults if the section is absent.
    func value<S: SettingsSection>(_ type: S.Type) -> S
}

/// A reader that always answers with defaults, and **discards every write**. The environment's
/// fallback, so a preview with no store configured still renders.
///
/// The discarding write is the dangerous half: a view whose subtree never received a real store
/// (most easily by sitting behind an `NSHostingView`/`NSHostingController` boundary, which
/// `@Environment` does not cross) will read plausible defaults and *appear* to save, losing the
/// user's change with no error. Treat reaching this type outside a `#Preview` as a wiring bug.
public struct DefaultSettingsReader: SettingsAccessing {
    public init() {}

    public func value<S: SettingsSection>(_ type: S.Type) -> S {
        S()
    }

    /// Discards `value`. See the type's documentation — this is a no-op, not a save.
    public func setValue<S: SettingsSection>(_ value: S) {}
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

public struct SettingsAccessorKey: EnvironmentKey {
    /// Defaults are a legitimate value here — a preview with no store configured should render.
    nonisolated(unsafe) public static let defaultValue: SettingsAccessing = DefaultSettingsReader()
}

public struct SettingsRevisionKey: EnvironmentKey {
    /// `0` forever: a subtree with no injector has no settings to change under it.
    public static let defaultValue: Int = 0
}

public extension EnvironmentValues {
    /// The settings accessor for the current view tree.
    ///
    /// Typed as ``SettingsAccessing`` rather than ``SettingsReading`` so that ``SettingsValue`` can
    /// vend a `Binding` from the same value it reads through.
    var settingsAccessor: SettingsAccessing {
        get { self[SettingsAccessorKey.self] }
        set { self[SettingsAccessorKey.self] = newValue }
    }

    /// Changes once per settings change; see ``Settings/revision``.
    ///
    /// The seam's invalidation signal, kept in its own `Equatable` key rather than folded into
    /// ``settingsAccessor``. Two keys, two jobs: the accessor answers *what the value is* and is
    /// legitimately a stable, stateless instance, while the revision answers *whether anything
    /// changed*. That separation is what lets a non-observing injection point (`appServices(_:)`)
    /// supply the accessor without also having to fake a change signal it cannot compute.
    ///
    /// Injected by any view that observes ``Settings``. A subtree that receives an accessor but no
    /// revision reads correct values and never re-renders on change — inject both, or neither.
    var settingsRevision: Int {
        get { self[SettingsRevisionKey.self] }
        set { self[SettingsRevisionKey.self] = newValue }
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
@propertyWrapper
public struct SettingsValue<S: SettingsSection, Value>: DynamicProperty {
    @Environment(\.settingsAccessor)
    private var accessor

    /// Not a source of data — a source of *invalidation*. See ``EnvironmentValues/settingsRevision``.
    @Environment(\.settingsRevision)
    private var revision

    private let keyPath: WritableKeyPath<S, Value>

    public init(_ section: S.Type, _ keyPath: WritableKeyPath<S, Value>) {
        self.keyPath = keyPath
    }

    public var wrappedValue: Value {
        get {
            // Read, not merely declared: an unread `@Environment` is a dependency SwiftUI does not
            // document itself as tracking, and being tracked is this property's entire purpose.
            _ = revision
            return accessor.value(S.self)[keyPath: keyPath]
        }
        // Read-modify-write of the whole section: the accessor is section-granular, and this is the
        // only way to change one field without naming the settings aggregate.
        nonmutating set {
            var section = accessor.value(S.self)
            section[keyPath: keyPath] = newValue
            accessor.setValue(section)
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
