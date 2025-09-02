//
//  InstantPopoverModifier.swift
//  CodeEdit
//
//  Created by Kihron on 10/26/24.
//

import SwiftUI

/// See ``SwiftUI/View/instantPopover(isPresented:arrowEdge:content:)``
/// - Warning: Views presented using this sheet must be dismissed by negating the `isPresented` binding. Using
///            SwiftUI's `dismiss` will likely cause a crash. See [FB16221871](rdar://FB16221871)
struct InstantPopoverModifier<PopoverContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let arrowEdge: Edge
    let popoverContent: PopoverContent

    func body(content: Content) -> some View {
        content
            .background(
                PopoverPresenter(
                    isPresented: $isPresented,
                    arrowEdge: arrowEdge,
                    contentView: popoverContent
                )
            )
    }
}

/// See ``SwiftUI/View/instantPopover(isPresented:arrowEdge:content:)``
/// - Warning: Views presented using this sheet must be dismissed by negating the `isPresented` binding. Using
///            SwiftUI's `dismiss` will likely cause a crash. See [FB16221871](rdar://FB16221871)
struct PopoverPresenter<ContentView: View>: NSViewRepresentable {
    @Binding var isPresented: Bool
    let arrowEdge: Edge
    let contentView: ContentView

    func makeNSView(context: Context) -> NSView { NSView() }

    func updateNSView(_ nsView: NSView, context: Context) {
        if isPresented && context.coordinator.popover == nil {
            let popover = NSPopover()
            popover.animates = false
            let hostingController = NSHostingController(rootView: contentView)

            hostingController.view.layoutSubtreeIfNeeded()
            let contentSize = hostingController.view.fittingSize
            popover.contentSize = contentSize

            popover.contentViewController = hostingController
            popover.delegate = context.coordinator
            popover.behavior = .semitransient

            let nsRectEdge = edgeToNSRectEdge(arrowEdge)
            popover.show(relativeTo: nsView.bounds, of: nsView, preferredEdge: nsRectEdge)
            context.coordinator.popover = popover

            if let parentWindow = nsView.window {
                context.coordinator.startObservingWindow(parentWindow)
            }
        } else if !isPresented, let popover = context.coordinator.popover {
            popover.close()
            context.coordinator.popover = nil
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    class Coordinator: NSObject, NSPopoverDelegate {
        @Binding var isPresented: Bool
        var popover: NSPopover?

        init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
            super.init()
        }

        func startObservingWindow(_ window: NSWindow) {
            /// Observe when the window loses focus
            NotificationCenter.default.addObserver(
                forName: NSWindow.didResignKeyNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                /// The parent window is no longer focused, close the popover
                DispatchQueue.main.async {
                    self.isPresented = false
                    self.popover?.close()
                }
            }
        }

        func popoverWillClose(_ notification: Notification) {
            DispatchQueue.main.async {
                self.isPresented = false
            }
        }

        func popoverDidClose(_ notification: Notification) {
            popover = nil
        }
    }

    private func edgeToNSRectEdge(_ edge: Edge) -> NSRectEdge {
        switch edge {
        case .top: return .minY
        case .leading: return .minX
        case .bottom: return .maxY
        case .trailing: return .maxX
        }
    }
}

extension View {
    /// A custom view modifier that presents a popover attached to the view with no animation.
    /// - Warning: Views presented using this sheet must be dismissed by negating the `isPresented` binding. Using
    ///            SwiftUI's `dismiss` will likely cause a crash. See [FB16221871](rdar://FB16221871)
    /// - Parameters:
    ///   - isPresented: A binding to whether the popover is presented.
    ///   - arrowEdge: The edge of the view that the popover points to. Defaults to `.bottom`.
    ///   - content: A closure returning the content of the popover.
    /// - Returns: A view that presents a popover when `isPresented` is `true`.
    func instantPopover<Content: View>(
        isPresented: Binding<Bool>,
        arrowEdge: Edge = .bottom,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            InstantPopoverModifier(
                isPresented: isPresented,
                arrowEdge: arrowEdge,
                popoverContent: PopoverContainer(content: content)
            )
        )
    }
}
