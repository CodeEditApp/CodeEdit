//
//  ServiceWrapper.swift
//  CodeEditV2
//
//  Created by Abe Malla on 3/20/24.
//

@propertyWrapper
struct Service<Service> {

    var service: Service

    init(_ type: ServiceType = .singleton) {
        guard let service = ServiceContainer.resolve(type, Service.self) else {
            let serviceName = String(describing: Service.self)
            fatalError("No service of type \(serviceName) registered!")
        }

        self.service = service
    }

    var wrappedValue: Service {
        get { self.service }
        mutating set { service = newValue }
    }
}
