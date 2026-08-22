//
//  ExtensionActivatorView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 30/12/2022.
//

import SwiftUI
import ExtensionKit

struct ExtensionActivatorView: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> EXAppExtensionBrowserViewController {
        EXAppExtensionBrowserViewController()
    }

    func updateNSViewController(_ nsViewController: EXAppExtensionBrowserViewController, context: Context) {

    }

    func makeCoordinator() {

    }
}

struct ExtensionActivatorView_Previews: PreviewProvider {
    static var previews: some View {
        ExtensionActivatorView()
    }
}
