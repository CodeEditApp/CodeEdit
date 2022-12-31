//
//  ExtensionActivatorView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 30/12/2022.
//

import SwiftUI
import ExtensionKit

struct ExtensionActivatorView: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> some NSViewController {
        EXAppExtensionBrowserViewController()
    }

    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {

    }

    func makeCoordinator() -> () {

    }
}

struct ExtensionActivatorView_Previews: PreviewProvider {
    static var previews: some View {
        ExtensionActivatorView()
    }
}

struct ExtensionHostView: NSViewControllerRepresentable {

    let appExtension: CEExtension

    init(with appExtension: CEExtension) {
        self.appExtension = appExtension
    }

    func makeNSViewController(context: Context) -> EXHostViewController {
        let controller = EXHostViewController()
        controller.delegate = context.coordinator
        controller.configuration = .some(.init(appExtension: appExtension, sceneID: "TestTest"))

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
