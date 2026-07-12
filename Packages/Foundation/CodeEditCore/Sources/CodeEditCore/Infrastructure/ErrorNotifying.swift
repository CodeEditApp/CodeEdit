//
//  ErrorNotifying.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom on 12/07/2026.
//

import Foundation

/// Posts a user-visible error notification. A one-method seam so packages can
/// surface errors without depending on the CENotifications feature package.
public protocol ErrorNotifying: AnyObject {
    @MainActor func postError(title: String, description: String)
}

public final class NoOpErrorNotifier: ErrorNotifying {
    public init() {}
    @MainActor public func postError(title: String, description: String) {}
}
