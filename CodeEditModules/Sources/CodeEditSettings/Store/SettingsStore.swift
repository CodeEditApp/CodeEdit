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
/// Not `@MainActor`: it is constructed and used from the main actor in practice, but isolating it
/// would break the deliberately-nonisolated ``SettingsAccessing`` conformance added in Task 3.
public final class SettingsStore {

    private var sections: [String: JSONValue]

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

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
            guard let raw = sections[S.settingsKey],
                  let data = try? encoder.encode(raw),
                  let decoded = try? decoder.decode(S.self, from: data)
            else {
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
            sections[S.settingsKey] = raw
        }
    }

    /// Every section read from disk, including ones nothing is registered to decode.
    public func encoded() throws -> Data {
        let data = try encoder.encode(sections)
        let object = try JSONSerialization.jsonObject(with: data)
        return try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
    }
}
