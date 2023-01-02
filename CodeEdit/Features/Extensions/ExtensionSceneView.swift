//
//  ExtensionSceneView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 31/12/2022.
//

import SwiftUI
import ExtensionKit
import ExtensionFoundation

struct ExtensionSceneView: NSViewControllerRepresentable {

    let appExtension: AppExtensionIdentity
    let sceneID: String

    init(with appExtension: AppExtensionIdentity, sceneID: String) {
        self.appExtension = appExtension
        self.sceneID = sceneID
    }

    func makeNSViewController(context: Context) -> EXHostViewController {
        let controller = EXHostViewController()
        controller.delegate = context.coordinator
        controller.configuration = .some(.init(appExtension: appExtension, sceneID: sceneID))

        return controller
    }

    func updateNSViewController(_ nsViewController: EXHostViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public class Coordinator: NSObject, EXHostViewControllerDelegate {
        var isOnline: Bool = false
        var toPublish: Data?
        public var connection: NSXPCConnection?



        public func hostViewControllerWillDeactivate(_ viewController: EXHostViewController, error: Error?) {
            isOnline = false
        }

        public func hostViewControllerDidActivate(_ viewController: EXHostViewController) {
            isOnline = true
            do {
                self.connection = try viewController.makeXPCConnection()
                //                connection?.remoteObjectInterface = .init(with: EnvironmentPublisherObjc.self)
                connection?.resume()
                //                if let toPublish {
                //                    Task {
                //                        try? await connection?.withService { (service: EnvironmentPublisherObjc) in
                //                            service.publishEnvironment(data: toPublish)
                //                        }
                //                    }
                //                }
            } catch {
                print("Unable to create connection: \(String(describing: error))")
            }
        }
    }
}
