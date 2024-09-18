//
//  LazyServiceWrapper.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/9/24.
//

/// A property wrapper that provides lazily-loaded access to a service instance.
///
/// Using this wrapper, the service is only resolved when the property is first accessed.
@propertyWrapper
struct LazyService<Service> {
    private let type: ServiceType
    private var service: Service?

    init(_ type: ServiceType = .singleton) {
        self.type = type
    }

    var wrappedValue: Service {
        mutating get {
            if let service {
                return service
            } else {
                guard let resolvedService = ServiceContainer.resolve(type, Service.self) else {
                    let serviceName = String(describing: Service.self)
                    fatalError("No service of type \(serviceName) registered!")
                }
                self.service = resolvedService
                return resolvedService
            }
        } mutating set {
            self.service = newValue
        }
    }
}
