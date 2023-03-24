//
//  ExtensionSceneView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 31/12/2022.
//

import SwiftUI
import CodeEditKit
import ExtensionKit
import ExtensionFoundation

struct ExtensionSceneView: NSViewControllerRepresentable {

    @Environment(\.openWindow) var openWindow

    let appExtension: AppExtensionIdentity
    let sceneID: String

    init(with appExtension: AppExtensionIdentity, sceneID: String) {
        self.appExtension = appExtension
        self.sceneID = sceneID
    }

    func makeNSViewController(context: Context) -> EXHostViewController {
        print("Making...")
        let controller = EXHostViewController()
        controller.delegate = context.coordinator
        controller.configuration = .some(.init(appExtension: appExtension, sceneID: sceneID))
        context.coordinator.updateEnvironment(context.environment._ceEnvironment)
        return controller
    }

    func updateNSViewController(_ nsViewController: EXHostViewController, context: Context) {
        print("Updating....")
        nsViewController.configuration = .init(appExtension: appExtension, sceneID: sceneID)
        context.coordinator.updateEnvironment(context.environment._ceEnvironment)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator { id in
            print(id)
            DispatchQueue.main.async {
                openWindow(id: id)
            }
        }
    }

    public class Coordinator: NSObject, EXHostViewControllerDelegate, EnvironmentPublisherObjc {
        var isOnline: Bool = false
        var toPublish: Data?
        var openWindow: (String) -> Void

        init(openWindow: @escaping (String) -> Void) {
            self.openWindow = openWindow
        }

        public var connection: NSXPCConnection?

        public func publishEnvironment(data: Data) {
            @Decoded<Callbacks> var data = data
            print("RECEIVED DATA")
            guard let $data else { return }
            switch $data {
            case .openWindow(let id):
                openWindow(id)
            }
        }

        public func updateEnvironment(@Encoded _ value: _CEEnvironment) {
            guard let $value else { return }

            guard isOnline else {
                toPublish = $value
                return
            }

            print("update: sending...")

            Task {
                do {
                    try await connection!.withService { (service: EnvironmentPublisherObjc) in
                        service.publishEnvironment(data: $value)
                    }
                } catch {
                    print(error)
                }
            }
        }

        public func hostViewControllerWillDeactivate(_ viewController: EXHostViewController, error: Error?) {
            isOnline = false
            print("Host will deactivate")
        }

        public func hostViewControllerDidActivate(_ viewController: EXHostViewController) {
            print("Host will activate")
            isOnline = true
            do {
                self.connection = try viewController.makeXPCConnection()
                connection?.exportedInterface = .init(with: EnvironmentPublisherObjc.self)
                connection?.exportedObject = self
                connection?.remoteObjectInterface = .init(with: EnvironmentPublisherObjc.self)
                connection?.resume()
                if let toPublish {
                    print("Sending first environment: \(String(data: toPublish, encoding: .utf8))")
                    Task {
                        try? await connection?.withService { (service: EnvironmentPublisherObjc) in
                            service.publishEnvironment(data: toPublish)
                        }
                    }
                }
            } catch {
                print("Unable to create connection: \(String(describing: error))")
            }
        }
    }
}
