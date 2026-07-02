//
//  EventBus.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 01.07.26.
//

import Combine
import Foundation

/// Typed, Combine-backed publish/subscribe event bus.
///
/// Each event type has its own `PassthroughSubject`. Publishing is synchronous
/// on the calling thread. Register as a Factory singleton via `Container.eventBus`.
///
/// **Publishing:**
/// ```swift
/// eventBus.publish(WelcomeWindowRequestedEvent())
/// ```
///
/// **Subscribing:**
/// ```swift
/// eventBus.subscribe(WelcomeWindowRequestedEvent.self)
///     .receive(on: RunLoop.main)
///     .sink { event in ... }
///     .store(in: &cancellables)
/// ```
public final class EventBus: @unchecked Sendable {
    private var subjects: [ObjectIdentifier: Any] = [:]
    private let lock = NSLock()

    public init() {}

    /// Publish an event to all current subscribers.
    public func publish<E: Event>(_ event: E) {
        subject(for: E.self).send(event)
    }

    /// Returns a publisher that emits events of the given type.
    public func subscribe<E: Event>(_ type: E.Type) -> AnyPublisher<E, Never> {
        subject(for: type).eraseToAnyPublisher()
    }

    private func subject<E: Event>(for type: E.Type) -> PassthroughSubject<E, Never> {
        lock.lock(); defer { lock.unlock() }
        let key = ObjectIdentifier(type)
        if let existing = subjects[key] as? PassthroughSubject<E, Never> {
            return existing
        }
        let created = PassthroughSubject<E, Never>()
        subjects[key] = created
        return created
    }
}
