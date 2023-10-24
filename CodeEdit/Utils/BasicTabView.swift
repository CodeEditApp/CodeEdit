//
//  BasicTabView.swift
//  CodeEdit
//
//  Created by Wouter on 20/10/23.
//

import SwiftUI
import Engine
import UniformTypeIdentifiers

struct BasicTabView<Content: View, Selected: Hashable>: View {
    @Binding var selection: Selected

    var tabPosition: SettingsData.SidebarTabBarPosition = .top

    @ViewBuilder var content: Content

    var body: some View {
        VariadicViewAdapter {
            content
        } content: { view in
            let children = view.children

            if !children.isEmpty {
                let items: [AreaTabBarAlt<Selected>.Tab] = children.map {
                    return .init(
                        title: $0[TabTitle.self],
                        image: $0[TabIcon.self] ?? Image(systemName: "questionmark.app.fill"),
                        id: $0.id,
                        tag: $0.tag(as: Selected.self),
                        onMove: $0.onMove(),
                        onDelete: $0.onDelete,
                        onInsert: $0.onInsert,
                        dynamicViewID: $0.dynamicViewContentID,
                        dynamicViewContentOffset: $0.contentOffset
                    )
                }

                let layout = tabPosition == .side ? AnyLayout(HStackLayout(spacing: .zero)) : AnyLayout(VStackLayout(spacing: .zero))
                
                    layout {
                        AreaTabBarAlt(items: items, selection: $selection, position: tabPosition)
                        Divider()
                        InternalBasicTabView(children: children, selected: children.firstIndex {
                            $0.tag(as: Selected.self) == self.selection
                        })
                    }
            }
        }
    }
}

extension AnyVariadicView.Subview {
    public func onMove() -> ((IndexSet, Int) -> Void)? {
        self["s7SwiftUI14OnMoveTraitKeyV", as: ((IndexSet, Int) -> Void).self]
    }
    
    var onDelete: ((IndexSet) -> Void)? {
        self["s7SwiftUI16OnDeleteTraitKeyV", as: ((IndexSet) -> Void).self]
    }
    
    var onInsert: OnInsertConfiguration? {
        let name = "s7SwiftUI16OnInsertTraitKeyV"
        let type = swift_getTypeByMangledNameInContext(name, UInt(name.count), genericContext: nil, genericArguments: nil)!
        let item = self["s7SwiftUI16OnInsertTraitKeyV", as: Any.self]

        return unsafePartialBitCast(item, to: OnInsertConfiguration?.self)
    }
    
    var contentOffset: Int? {
        self["s7SwiftUI32DynamicViewContentOffsetTraitKeyV", as: Int.self]
    }
    
    var dynamicViewContentID: Int? {
        self["s7SwiftUI28DynamicViewContentIDTraitKeyV", as: Int.self]
    }
}

struct OnInsertConfiguration {
     
    var supportedContentTypes: [UTType] = []
    var action: (Int, [NSItemProvider]) -> Void
//    var index: Int = 0

}

private struct TabIcon: _ViewTraitKey {
    static var defaultValue: Image?
}

private struct TabTitle: _ViewTraitKey {
    static var defaultValue: String?
}

struct OnMoveTab: EnvironmentKey {
    static var defaultValue: ((Int, Int) -> Void)?
}

private struct OnMoveTabE: _ViewTraitKey {
    static var defaultValue: ((Int, Int) -> Void)?
}

@_silgen_name("swift_getTypeByMangledNameInContext")
private func swift_getTypeByMangledNameInContext(
  _ name: UnsafePointer<UInt8>,
  _ nameLength: UInt,
  genericContext: UnsafeRawPointer?,
  genericArguments: UnsafeRawPointer?
)
  -> Any.Type?

extension EnvironmentValues {
    var onMoveTab: OnMoveTab.Value {
        get { self[OnMoveTab.self] }
        set { self[OnMoveTab.self] = newValue }
    }
}

extension SwiftUI.DynamicViewContent {
    func onMoveTab(perform action: @escaping (Int, Int) -> Void) -> some DynamicViewContent {
        modifier(_TraitWritingModifier<OnMoveTabE>(value: action))
    }
}

extension View {
    func tabIcon(_ value: Image) -> some View {
        _trait(TabIcon.self, value)
    }

    func tabTitle(_ value: String) -> some View {
        _trait(TabTitle.self, value)
    }

    func onMoveTab(perform action: @escaping (Int, Int) -> Void) -> some View {
        environment(\.onMoveTab, action)
    }
}

private struct InternalBasicTabView: NSViewControllerRepresentable {

    let children: AnyVariadicView
    let selected: Int?

    func makeNSViewController(context: Context) -> NSTabViewController {
        let controller = NSTabViewController()
        controller.tabStyle = .unspecified
        return controller
    }

    func updateNSViewController(_ nsViewController: NSTabViewController, context: Context) {
        var newDict: [AnyHashable: NSTabViewItem] = [:]
        var childViews: [NSTabViewItem] = []

        for child in children {
            let oldChild = context.coordinator.children[child.id]
            let newChild = oldChild ?? NSTabViewItem(viewController: NSHostingController(rootView: child))
            newDict[child.id] = newChild
            childViews.append(newChild)
        }

        context.coordinator.children = newDict
        DispatchQueue.main.async {
            nsViewController.tabViewItems = childViews
            nsViewController.selectedTabViewItemIndex = min(selected ?? 0, children.count-1)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var children: [AnyHashable: NSTabViewItem] = [:]
    }
}
