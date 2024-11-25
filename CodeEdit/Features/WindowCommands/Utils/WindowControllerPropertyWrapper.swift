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

        private var objectWillChangeCancellable: AnyCancellable?
        private var utilityAreaCancellable: AnyCancellable? // ``ViewCommands`` needs this.
        private var windowCancellable: AnyCancellable?
        private var activeEditorCancellable: AnyCancellable?

        init() {
            windowCancellable = NSApp.publisher(for: \.keyWindow).receive(on: RunLoop.main).sink { [weak self] window in
                // Fix an issue where NSMenuItems with custom views would trigger this callback.
                guard window?.className != "NSPopupMenuWindow" else { return }
                self?.setNewController(window?.windowController as? CodeEditWindowController)
            }
        }

        func setNewController(_ controller: CodeEditWindowController?) {
            objectWillChangeCancellable?.cancel()
            objectWillChangeCancellable = nil
            utilityAreaCancellable?.cancel()
            utilityAreaCancellable = nil
            activeEditorCancellable?.cancel()
            activeEditorCancellable = nil

            self.controller = controller

            objectWillChangeCancellable = controller?.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }
            utilityAreaCancellable = controller?.workspace?.utilityAreaModel?.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }
            let activeEditor = controller?.workspace?.editorManager?.activeEditor
            activeEditorCancellable = activeEditor?.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }
            self.objectWillChange.send()
        }
    }
}
