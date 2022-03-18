//
//  WelcomeView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import AppKit
import Foundation

struct WelcomeView: View {
    @State var isHovering: Bool = false
    @AppStorage("showWelcomeWindowWhenLaunch") var showWelcomeWindowWhenLaunch: Bool = true
    
    var dismissWindow: () -> Void
    
    var dismissButton: some View {
        Image(systemName: "xmark")
            .frame(width: 16, height: 16)
            .onTapGesture {
                dismissWindow()
            }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                if (isHovering) {
                    dismissButton
                }
                Spacer()
            }.frame(height: 20)
            Image("appicon")
                .resizable()
                .frame(width: 128, height: 128)
            Text("Welcome to CodeEdit")
                .bold()
                .font(.system(size: 28))
            Text("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)(\(NSApplication.version()))")
                .foregroundColor(.gray)
                .font(.system(size: 16))
            Spacer().frame(height: 20)
            HStack {
                VStack(alignment: .leading, spacing: 15) {
                    WelcomeActionView(
                        iconName: "plus.square",
                        title: "Create a new file",
                        subtitle: "Create a new file"
                    )
                        .onTapGesture {
                            // TODO: open a new empty editor
                        }
                    WelcomeActionView(
                        iconName: "plus.square.on.square",
                        title: "Clone an exisiting project",
                        subtitle: "Start working on something from a Git repository"
                    )
                        .onTapGesture {
                            // TODO: clone a Git repository
                        }
                    WelcomeActionView(
                        iconName: "folder",
                        title: "Open a project or file",
                        subtitle: "Open an existing project or file on your Mac"
                    )
                        .onTapGesture {
                            CodeEditDocumentController.shared.openDocument { _, _, _ in
                                dismissWindow()
                            }
                        }
                }
            }
            Spacer()
            if (isHovering) {
                HStack {
                    Toggle("Show this window then Xcode launches", isOn: $showWelcomeWindowWhenLaunch)
                        .toggleStyle(.checkbox)
                    Spacer()
                }
            }
        }
        .frame(width: 480)
        .padding(.vertical, 24)
        .padding(.horizontal, 32)
        .background(Color(red: 48 / 255, green: 48 / 255, blue: 48 / 255))
        .onHover { isHovering in
            self.isHovering = isHovering
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView() {
            
        }
        .frame(width: 780, height: 600)
    }
}
