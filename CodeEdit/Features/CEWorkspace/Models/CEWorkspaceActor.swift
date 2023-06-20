//
//  CEWorkspaceActor.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 19/06/2023.
//

import Foundation
import AppKit
import SwiftUI

protocol ResourceData: AnyObject, Identifiable {
    var name: String { get set }
    var url: URL { get set }

    var parentFolder: Folder? { get set }

    func resolveItem(components: [String]) -> any ResourceData

    func update(with url: URL) throws

    var iconColor: Color { get }

    var systemImage: String { get }

    func fileName(typeHidden: Bool) -> String
}

extension ResourceData {
    var id: URL { url }

    var children2: [any ResourceData]? {
        guard let self = self as? Folder else { return nil }
        return self.children
    }
}

enum Resource: Equatable {

    enum Ignored: Hashable {
        case file(name: String)
        case folder(name: String)
        case url(URL)
    }
}
