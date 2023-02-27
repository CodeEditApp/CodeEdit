//
//  SequenceView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 22/02/2023.
//

import SwiftUI

// swiftlint:disable identifier_name
struct Helper<Result: View>: _VariadicView_UnaryViewRoot {
    var _body: (_VariadicView.Children) -> Result

    func body(children: _VariadicView.Children) -> some View {
        _body(children)
    }
}

extension View {
    func variadic<R: View>(@ViewBuilder process: @escaping (_VariadicView.Children) -> R) -> some View {
        _VariadicView.Tree(Helper(_body: process), content: { self })
    }
}

struct SplitView<Content: View>: View {
    var content: Content

    @State var viewController: SplitViewController

    init(axis: Axis, @ViewBuilder content: () -> Content) {
        self.content = content()
        let vc = SplitViewController(axis: axis)
        self._viewController = .init(wrappedValue: vc)
    }

    var body: some View {
        VStack {
            content.variadic { children in
                EditorSplitView(children: children, viewController: viewController)
            }
        }
        ._trait(SplitViewControllerLayoutValueKey.self, viewController)
    }
}

struct SplitViewReader<Content: View>: View {

    @ViewBuilder var content: (SplitViewProxy) -> Content

    @State private var viewController: SplitViewController?

    private var proxy: SplitViewProxy {
        .init {
            viewController
        }
    }

    var body: some View {
        content(proxy)
            .variadic { children in
                ForEach(children, id: \.id) { child in
                    child
                        .task {
                            if let vc = child[SplitViewControllerLayoutValueKey.self] {
                                viewController = vc
                            }
                        }
                }
            }
    }
}

struct SplitViewProxy {
    private var viewController: () -> SplitViewController?

    fileprivate init(viewController: @escaping () -> SplitViewController?) {
        self.viewController = viewController
    }

    func setPosition(of index: Int, position: CGFloat) {
        viewController()?.splitView.setPosition(position, ofDividerAt: index)
    }

    func collapseView(with id: AnyHashable, _ enabled: Bool) {
        viewController()?.collapse(for: id, enabled: enabled)
    }
}

struct SplitViewControllerLayoutValueKey: _ViewTraitKey {
    static var defaultValue: SplitViewController?
}

struct SplitViewItemCollapsedViewTraitKey: _ViewTraitKey {
    static var defaultValue: Binding<Bool> = .constant(false)
}

struct SplitViewItemCanCollapseViewTraitKey: _ViewTraitKey {
    static var defaultValue: Bool = false
}

struct SplitViewItemMinimumHeightViewTraitKey: _ViewTraitKey {
    static var defaultValue: Bool = false
}

struct SplitViewItemMaximumHeightViewTraitKey: _ViewTraitKey {
    static var defaultValue: Bool = false
}

extension View {
    func collapsed(_ value: Binding<Bool>) -> some View {
        self
            // Use get/set instead of binding directly, so a view update will be triggered if the binding changes.
            ._trait(SplitViewItemCollapsedViewTraitKey.self, .init {
                value.wrappedValue
            } set: {
                value.wrappedValue = $0
            })
    }

    func collapsable() -> some View {
        self
            ._trait(SplitViewItemCanCollapseViewTraitKey.self, true)
    }
}
