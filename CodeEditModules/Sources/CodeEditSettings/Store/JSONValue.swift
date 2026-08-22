//
//  JSONValue.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 10/08/26.
//

import Foundation

/// A parsed JSON tree, used to hold settings sections nothing is registered to decode.
///
/// This is what lets a disabled, uninstalled or not-yet-loaded extension's configuration survive a
/// save: the store re-emits these verbatim rather than dropping keys it does not understand.
public enum JSONValue: Codable, Hashable, Sendable {
    case null
    case bool(Bool)
    case integer(Int)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // Order matters. `Bool` before the numerics: Foundation will decode `true` as `1` if a
        // numeric type is tried first, which would rewrite booleans as numbers on save. `Int`
        // before `Double`: decoding `42` as `Double` re-emits it as `42` today but loses the
        // integer/float distinction the file was written with.
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .integer(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else {
            self = .object(try container.decode([String: JSONValue].self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case .bool(let value): try container.encode(value)
        case .integer(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .string(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        }
    }
}
