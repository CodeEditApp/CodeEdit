import SwiftUI

struct IsOverlayKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

struct IsSingleListItemKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isOverlay: Bool {
        get { self[IsOverlayKey.self] }
        set { self[IsOverlayKey.self] = newValue }
    }
    
    var isSingleListItem: Bool {
        get { self[IsSingleListItemKey.self] }
        set { self[IsSingleListItemKey.self] = newValue }
    }
}
