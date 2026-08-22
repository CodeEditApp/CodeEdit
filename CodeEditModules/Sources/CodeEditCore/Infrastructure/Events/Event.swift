//
//  Event.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 01.07.26.
//

/// Marker protocol for all typed EventBus events.
///
/// Conforming types are published via `EventBus` and received by subscribers
/// via `AnyCancellable`. All events must be `Sendable`.
public protocol Event: Sendable {}
