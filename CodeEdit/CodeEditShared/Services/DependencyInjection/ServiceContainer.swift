//
//  ServiceContainer.swift
//  CodeEditV2
//
//  Created by Abe Malla on 3/20/24.
//

final class ServiceContainer {
    private static var factories: [String: () -> Any] = [:]
    private static var cache: [String: Any] = [:]

    static func register<Service>(type: Service.Type, _ factory: @autoclosure @escaping () -> Service) {
        factories[String(describing: type.self)] = factory
    }
    
    static func resolve<Service>(_ resolveType: ServiceType = .singleton, _ type: Service.Type) -> Service? {
        let serviceName = String(describing: type.self)

        switch resolveType {
        case .singleton:
            if let service = cache[serviceName] as? Service {
                return service
            } else {
                let service = factories[serviceName]?() as? Service

                if let service = service {
                    cache[serviceName] = service
                }

                return service
            }
        case .newSingleton:
            let service = factories[serviceName]?() as? Service

            if let service = service {
                cache[serviceName] = service
            }

            return service
        case .new:
            return factories[serviceName]?() as? Service
        }
    }
}
