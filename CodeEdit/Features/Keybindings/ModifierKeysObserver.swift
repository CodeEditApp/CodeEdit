//
//  ModifierKeysObserver.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 04/03/2023.
//

import SwiftUI
import Combine

struct EventModifierEnvironmentKey: EnvironmentKey {
    static var defaultValue: NSEvent.ModifierFlags = []
}

extension EnvironmentValues {
    var modifierKeys: EventModifierEnvironmentKey.Value {
        get { self[EventModifierEnvironmentKey.self] }
        set { self[EventModifierEnvironmentKey.self] = newValue }
    }
}

extension NSEvent {
    static func publisher(scope: Publisher.Scope, matching: EventTypeMask) -> Publisher {
        return Publisher(scope: scope, matching: matching)
    }

    public struct Publisher: Combine.Publisher {
        public enum Scope {
            case local, global
        }

        public typealias Output = NSEvent

        public typealias Failure = Never

        let scope: Scope
        let matching: EventTypeMask

        init(scope: Scope, matching: EventTypeMask) {
            self.scope    = scope
            self.matching = matching
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = Subscription(scope: scope, matching: matching, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

private extension NSEvent.Publisher {
    final class Subscription<S: Subscriber> where S.Input == NSEvent, S.Failure == Never {
        fileprivate let lock = NSLock()
        fileprivate var demand = Subscribers.Demand.none
        private var monitor: Any?

        fileprivate let subscriberLock = NSRecursiveLock()

        init(scope: Scope, matching: NSEvent.EventTypeMask, subscriber: S) {
            switch scope {
            case .local:
                self.monitor = NSEvent.addLocalMonitorForEvents(matching: matching) { [weak self] (event) -> NSEvent? in
                    self?.didReceive(event: event, subscriber: subscriber)
                    return event
                }

            case .global:
                self.monitor = NSEvent.addGlobalMonitorForEvents(matching: matching) { [weak self] in
                    self?.didReceive(event: $0, subscriber: subscriber)
                }
            }

        }

        deinit {
            if let monitor = monitor {
                NSEvent.removeMonitor(monitor)
            }
        }

        func didReceive(event: NSEvent, subscriber: S) {
            let val = { () -> Subscribers.Demand in
                lock.lock()
                defer { lock.unlock() }
                let before = demand
                if demand > 0 {
                    demand -= 1
                }
                return before
            }()

            guard val > 0 else { return }

            let newDemand = subscriber.receive(event)

            lock.lock()
            demand += newDemand
            lock.unlock()
        }
    }
}

extension NSEvent.Publisher.Subscription: Combine.Subscription {
    func request(_ demand: Subscribers.Demand) {
        lock.lock()
        defer { lock.unlock() }
        self.demand += demand
    }

    func cancel() {
        lock.lock()
        defer { lock.unlock() }
        guard let monitor = monitor else { return }

        self.monitor = nil
        NSEvent.removeMonitor(monitor)
    }
}
