//
//  LanguageServer+Notifications.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/14/24.
//

import Foundation

extension LanguageServer {
    func setUpNotifications() {
        NotificationCenter.default.addObserver(
            forName: CodeFileDocument.didOpenNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let document = notification.object as? CodeFileDocument else { return }
            Task { @MainActor in
                try await self.openDocument(document)
            }
        }

        NotificationCenter.default.addObserver(
            forName: CodeFileDocument.didCloseNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let uri = notification.object as? URL else { return }
            Task { @MainActor in
                try await self.closeDocument(uri.languageServerURI)
            }
        }
    }
}
