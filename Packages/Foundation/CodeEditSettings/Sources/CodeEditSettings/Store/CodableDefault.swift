//
//  CodableDefault.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 07.04.26.
//

import Foundation

/// A type that provides a default value for a ``CodableDefault`` property wrapper.
///
/// Conform to this protocol to define a default value that will be used
/// when decoding fails or the key is missing from the JSON.
public protocol DefaultValueProvider {
    /// The type of the value being defaulted; must round-trip through `Codable`.
    associatedtype Value: Codable & Hashable
    /// The fallback value used when the key is missing from the JSON or its value fails to decode.
    static var defaultValue: Value { get }
}

/// A property wrapper that provides a default value when decoding from JSON
/// and the key is missing or the value cannot be decoded.
///
/// Usage:
/// ```swift
/// struct MySettings: Codable, Hashable {
///     @CodableDefault<DefaultTrue> var isEnabled: Bool
///     @CodableDefault<DefaultFalse> var isHidden: Bool
/// }
/// ```
///
/// With this wrapper, you no longer need a custom `init(from:)` for handling
/// missing keys — Swift's auto-synthesized decoder handles it automatically.
@propertyWrapper
public struct CodableDefault<Provider: DefaultValueProvider>: Codable, Hashable {
    public var wrappedValue: Provider.Value

    public init(wrappedValue: Provider.Value) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(Provider.Value.self)) ?? Provider.defaultValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

// MARK: - KeyedDecodingContainer Support

/// When a key is missing from the JSON, return the provider's default value
/// instead of throwing a `DecodingError.keyNotFound`.
extension KeyedDecodingContainer {
    func decode<P: DefaultValueProvider>(
        _ type: CodableDefault<P>.Type,
        forKey key: Key
    ) throws -> CodableDefault<P> {
        (try? decodeIfPresent(type, forKey: key)) ?? CodableDefault(wrappedValue: P.defaultValue)
    }
}
