//
//  ReopenBehavior.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 17.03.22.
//

import Foundation

enum ReopenBehavior: String, CaseIterable, Hashable {
    case welcome
    case openPanel
    case newDocument
    
    static let `default` = ReopenBehavior.welcome
    static let storageKey = "behavior"
}
