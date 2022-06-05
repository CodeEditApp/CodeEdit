//
//  WorkspaceDocument+CommandListeners.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/5/22.
//

import Foundation
import WorkspaceClient
import Combine

class WorkspaceNotificationModel: ObservableObject {
    init() {
        highlitedFileItem = nil
    }

    @Published var highlitedFileItem: WorkspaceClient.FileItem?
}
