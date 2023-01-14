//
//  InspectorToggler.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/01/2023.
//

import SwiftUI

struct SplitViewEnvironmentKey: EnvironmentKey {
    static var defaultValue: () -> Void = {
        let vc: NSSplitViewController? = NSApp.keyWindow?.contentView?.subviews.first?.subviews.first?.nextResponder as? NSSplitViewController
        vc?.toggleInspector()
    }
}

extension NSSplitViewController {

    @objc open func toggleInspector() {
        NSAnimationContext.runAnimationGroup() { ctx in
            ctx.duration = 0.5
            ctx.allowsImplicitAnimation = true
            splitViewItems.last?.isCollapsed.toggle()
        }
    }
}


extension EnvironmentValues {
    var toggleInspector: SplitViewEnvironmentKey.Value {
        get { self[SplitViewEnvironmentKey.self] }
        set { self[SplitViewEnvironmentKey.self] = newValue }
    }
}
