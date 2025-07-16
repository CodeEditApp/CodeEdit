//
//  WindowControllerPropertyWrapper.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/14/24.
//

import AppKit
import SwiftUI
import Combine

/// Provides an auto-updating reference to ``CodeEditWindowController``. The value will update as the key window
/// changes, and does not keep a strong reference to the controller.
///
/// Sample usage:
/// ```swift
/// struct WindowCommands: Commands {
///     @UpdatingWindowController var windowController
///
///     var body: some Commands {
///         Button("Button that needs the window") {
///             print("Window exists")
///         }
///         .disabled(windowController == nil)
///     }
/// }
/// ```
@propertyWrapper
struct UpdatingWindowController: DynamicProperty {
    @StateObject var box = WindowControllerBox()

    var wrappedValue: CodeEditWindowController? {
        box.controller
    }

    class WindowControllerBox: ObservableObject {
        public private(set) weak var controller: CodeEditWindowController?

        private var windowCancellable: AnyCancellable? // Needs to stick around between window changes.
        private var cancellables: Set<AnyCancellable> = []

        init() {
            windowCancellable = NSApp.publisher(for: \.keyWindow).receive(on: RunLoop.main).sink { [weak self] window in
                // Fix an issue where NSMenuItems with custom views would trigger this callback.
                guard window?.className != "NSPopupMenuWindow" else { return }
                self?.setNewController(window?.windowController as? CodeEditWindowController)
            }
        }

        func setNewController(_ controller: CodeEditWindowController?) {
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()

            self.controller = controller

            controller?.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

            controller?.workspace?.utilityAreaModel?.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

            let activeEditor = controller?.workspace?.editorManager?.activeEditor
            activeEditor?.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

            controller?.workspace?.taskManager?.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

            self.objectWillChange.send()
        }
    }
}
