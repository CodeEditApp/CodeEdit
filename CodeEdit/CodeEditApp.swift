//
//  CodeEditApp.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI

@main
struct CodeEdit: App {
    init() {
        setupServiceContainer()
    }

    var body: some Scene {
        WelcomeScene()
    }
}

private extension CodeEdit {
    func setupServiceContainer() {
        ServiceContainer.register(
            type: PasteboardService.self,
            PasteboardService()
        )
    }
}
