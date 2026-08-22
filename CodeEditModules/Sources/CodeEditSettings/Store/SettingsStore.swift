//
//  SettingsStore.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 10/08/26.
//

import Foundation

/// Settings storage keyed by section.
///
/// Sections nothing is registered to read are held as ``JSONValue`` and re-emitted verbatim on
/// save. That is what makes an unknown or disabled extension's configuration safe: the previous
/// store decoded only known keys and wrote only known keys, so a file written by a newer build lost
/// keys when an older build saved.
///
/// A section that is present but *undecodable* is read as its defaults, but is likewise held and
/// re-emitted verbatim — so a hand-edit this build cannot parse survives every save until something
/// writes that same section back. That write is announced through
/// ``willReplaceUndecodableSection`` so the owner can preserve the original first.
///
/// Not `@MainActor`: it is constructed and used from the main actor in practice, but isolating it
/// would break the deliberately-nonisolated ``SettingsAccessing`` conformance added in Task 3.
public final class SettingsStore {

    private var sections: [String: JSONValue]

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    /// Called with the section key immediately before a write replaces a stored value that this
    /// build could **not** decode.
    ///
    /// This is the store's one destructive moment, and the only one. A section that fails to decode
    /// reads as `S()`, but the raw JSON stays in `sections` and ``encoded()`` re-emits it verbatim,
    /// so the user's original survives every save — right up until something writes *that* section
    /// back, which replaces it with values that were never theirs. Nothing else in this type can lose
    /// data.
    ///
    /// Deliberately a callback rather than a policy: this target has no business knowing where the
    /// file lives or what "preserve" means. The owner (`PersistentSettingsStore`) copies the file aside.
    /// Called synchronously and before the replacement, so the handler still sees the original both
    /// in this store and on disk.
    public var willReplaceUndecodableSection: ((String) -> Void)?

    /// Keys already reported, so a section written repeatedly reports once.
    private var reportedUndecodableSections: Set<String> = []

    /// An empty store, with every section at its defaults.
    public init() {
        self.sections = [:]
    }

    /// Loads a store from a previously-encoded `settings.json`.
    public init(data: Data) throws {
        self.sections = try JSONDecoder().decode([String: JSONValue].self, from: data)
    }

    /// Reads or writes the section for `type`, falling back to its defaults when absent or
    /// undecodable.
    public subscript<S: SettingsSection>(_ type: S.Type) -> S {
        get {
            guard let raw = sections[S.settingsKey], let decoded = decode(raw, as: S.self) else {
                return S()
            }
            return decoded
        }
        set {
            guard let data = try? encoder.encode(newValue),
                  let raw = try? decoder.decode(JSONValue.self, from: data)
            else {
                assertionFailure("Section '\(S.settingsKey)' failed to round-trip through JSONValue")
                return
            }
            // Report *before* the assignment: this is the one point at which a value the user wrote
            // by hand, and this build could not read, stops existing.
            if let existing = sections[S.settingsKey],
               decode(existing, as: S.self) == nil,
               reportedUndecodableSections.insert(S.settingsKey).inserted {
                willReplaceUndecodableSection?(S.settingsKey)
            }
            sections[S.settingsKey] = raw
        }
    }

    /// Decodes one stored section, or `nil` when this build cannot read it.
    private func decode<S: SettingsSection>(_ raw: JSONValue, as type: S.Type) -> S? {
        guard let data = try? encoder.encode(raw) else { return nil }
        return try? decoder.decode(S.self, from: data)
    }

    /// Every section read from disk, including ones nothing is registered to decode.
    public func encoded() throws -> Data {
        let data = try encoder.encode(sections)
        let object = try JSONSerialization.jsonObject(with: data)
        return try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
    }
}
