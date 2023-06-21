//
//  CEWorkspaceActor.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 19/06/2023.
//

import Foundation
import AppKit
import SwiftUI

protocol Resource: AnyObject, Identifiable {
    var name: String { get set }
    var url: URL { get set }

    var parentFolder: Folder? { get set }

    func resolveItem(components: [String]) -> any Resource

    func update(with url: URL) throws

    var iconColor: Color { get }

    var systemImage: String { get }

    func fileName(typeHidden: Bool) -> String
}

extension Resource {
    var id: URL { url }

    func showInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    func openWithExternalEditor() {
        NSWorkspace.shared.open(url)
    }

    var icon: Image { Image(systemName: systemImage) }
}
