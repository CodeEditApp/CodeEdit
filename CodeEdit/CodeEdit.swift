//
//  CodeEdit.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/21.
//

import SwiftUI

@main
struct CodeEdit: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
                .frame(width: 500)
                .task {
                    try? await Task.sleep(nanoseconds: NSEC_PER_MSEC)
                    NSApp.keyWindow?.center()
                }
        }
    }
}
