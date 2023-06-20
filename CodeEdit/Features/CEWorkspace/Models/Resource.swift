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

    var children2: [any Resource]? {
        guard let self = self as? Folder else { return nil }
        return self.children
    }
}
