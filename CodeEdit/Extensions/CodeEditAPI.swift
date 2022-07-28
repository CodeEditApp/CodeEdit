//
//  CodeEditAPI.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation
import CodeEditKit

final class CodeEditAPI: ExtensionAPI {
     var extensionId: String
     var workspace: WorkspaceDocument

     var workspaceURL: URL {
         workspace.fileURL!
     }

     init(extensionId: String, workspace: WorkspaceDocument) {
         self.extensionId = extensionId
         self.workspace = workspace
     }

     lazy var targets: TargetsAPI = CodeEditTargetsAPI(workspace)
 }
