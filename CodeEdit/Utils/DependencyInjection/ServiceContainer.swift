//
//  ServiceContainer.swift
//  CodeEdit
//
//  Created by Abe Malla on 4/3/24.
//

import Foundation

enum ServiceContainer {
    private static var factories: [ObjectIdentifier: () -> Any] = [:]
    private static var cache: [ObjectIdentifier: Any] = [:]
    private static let queue = DispatchQueue(label: "ServiceContainerQueue")

    static func register<Service>(_ factory: @autoclosure @escaping () -> Service) {
        queue.sync {
            let key = ObjectIdentifier(Service.Type.self)
            factories[key] = factory
        }
    }

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
