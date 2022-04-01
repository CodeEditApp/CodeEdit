//
//  ReopenBehavior.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 17.03.22.
//

import Foundation

public enum ReopenBehavior: String, CaseIterable, Hashable {
    case welcome
    case openPanel
    case newDocument

    public static let `default` = ReopenBehavior.welcome
    public static let storageKey = "behavior"
}
