//
//  ServiceContainer.swift
//  CodeEdit
//
//  Created by Abe Malla on 4/3/24.
//

import Foundation

/// A service container that manages the registration and resolution of services.
enum ServiceContainer {
    /// A dictionary storing the closures for creating service instances.
    private static var factories: [ObjectIdentifier: () -> Any] = [:]
    /// A dictionary storing the cached service instances.
    private static var cache: [ObjectIdentifier: Any] = [:]
    /// A dispatch queue used for synchronizing access to the factories and cache.
    private static let queue = DispatchQueue(label: "ServiceContainerQueue")

    /// Registers a factory closure for creating instances of a service type.
    ///
    /// - Parameter factory: An autoclosure that returns an instance of the service type.
    static func register<Service>(_ factory: @autoclosure @escaping () -> Service) {
        queue.sync {
            let key = ObjectIdentifier(Service.Type.self)
            factories[key] = factory
        }
    }

    /// Resolves an instance of a service type based on the specified resolution type.
    ///
    /// - Parameters:
    ///   - resolveType: The type of resolution to use for the service. Defaults to `.singleton`.
    ///   - type: The type of the service to resolve.
    /// - Returns: An instance of the resolved service type, or `nil` if the service is not registered.
    static func resolve<Service>(_ resolveType: ServiceType = .singleton, _ type: Service.Type) -> Service? {
        let serviceId = ObjectIdentifier(Service.Type.self)

        return queue.sync {
            switch resolveType {
            case .singleton:
                if let service = cache[serviceId] as? Service {
                    return service
                } else {
                    let service = factories[serviceId]?() as? Service

                    if let service = service {
                        cache[serviceId] = service
                    }

                    return service
                }
            case .newSingleton:
                let service = factories[serviceId]?() as? Service

                if let service = service {
                    cache[serviceId] = service
                }

                return service
            case .new:
                return factories[serviceId]?() as? Service
            }
        }
    }
}
