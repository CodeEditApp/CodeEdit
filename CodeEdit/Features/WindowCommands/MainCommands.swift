//
//  MainCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI

struct MainCommands: Commands {

    @ObservedObject var appDelegate: AppDelegate

    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Group {
                Button("About CodeEdit") {
                    NSApp.orderFrontStandardAboutPanel(nil)
                }

                Button("Check for Updates...") {

                }
            }

            Divider()

            Button("Settings...") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
            .keyboardShortcut(",")

            Button("Old Settings...") {
                appDelegate.openPreferences(self)
            }
            .keyboardShortcut(",", modifiers: [.command, .hiddenOption])

            Divider()

            Group {
                Button("Hide CodeEdit") {
                    NSApp.hide(nil)
                }
                .keyboardShortcut("h", modifiers: [.command])
                
                Button("Hide Others") {
                    NSApp.hideOtherApplications(nil)
                }
                .keyboardShortcut("h", modifiers: [.command, .option])
                
                Button("Show All") {
                    NSApp.unhideAllApplications(nil)
                }
            }

            Divider()

            Button("Quit CodeEdit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")

            Button("Quit and Keep Windows") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [.command, .hiddenOption])
        }
    }
}

extension EventModifiers {
    static var hiddenOption: EventModifiers = [.option, .numericPad]
}

extension NSMenuItem {

    @objc
    func fixAlternate(_ newValue: NSEvent.ModifierFlags) {

        print(title, action)

        if newValue.contains(.numericPad) {

            isAlternate = true
            fixAlternate(newValue.subtracting(.numericPad))
        }

        fixAlternate(newValue)
    }

    static func swizzle() {
        let originalMethodSet = class_getInstanceMethod(self as AnyClass, #selector(setter: NSMenuItem.keyEquivalentModifierMask))
        let swizzledMethodSet = class_getInstanceMethod(self as AnyClass, #selector(fixAlternate))

        method_exchangeImplementations(originalMethodSet!, swizzledMethodSet!)

    }
}
