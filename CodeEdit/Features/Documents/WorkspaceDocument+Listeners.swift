//
//  WorkspaceDocument+CommandListeners.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/5/22.
//

import Foundation
import Combine

// TODO: This needs to be reworked
class WorkspaceNotificationModel: ObservableObject {

    @Published var highlightedFileItem: File?

    init() {
        highlightedFileItem = nil
    }

}
