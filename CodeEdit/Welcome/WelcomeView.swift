//
//  WelcomeView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import AppKit
import Foundation
import WelcomeModule

struct WelcomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var isHovering: Bool = false
    @State var isHoveringClose: Bool = false
    @AppStorage(ReopenBehavior.storageKey) var behavior: ReopenBehavior = .welcome
    var dismissWindow: () -> Void

    private var dismissButton: some View {
        Button(action: dismissWindow, label: {
            Circle()
                .fill(isHoveringClose ? .secondary : Color(.clear))
                .frame(width: 13, height: 13)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.system(size: 8.5, weight: .heavy, design: .rounded))
                        .foregroundColor(isHoveringClose ? Color(nsColor: .windowBackgroundColor) : .secondary)
                )
        })
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(Text("Close"))
        .onHover { hover in
            isHoveringClose = hover
        }
    }

    private var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    private var appBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }
    
    private var macOsVersion: String {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        return "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
    }
    
    private var xCodeVersion: String {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.dt.Xcode"),
              let bundle = Bundle(url: url) else {
            print("Xcode is not installed")
            exit(1)
        }
        
        guard let infoDict = bundle.infoDictionary,
              let version = infoDict["CFBundleShortVersionString"] as? String else {
            print("No version found in Info.plist")
            exit(1)
        }
        
        return version
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 8) {
                Spacer().frame(height: 12)
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 128, height: 128)
                Text("Welcome to CodeEdit")
                    .font(.system(size: 38))
                Text("Version \(appVersion) (\(appBuild))")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))
                    .onHover { inside in
                        if inside {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .onTapGesture {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(
                            "CodeEdit: \(appVersion) (\(appBuild))\n" +
                            "MacOS: \(macOsVersion)\n" +
                            "Xcode: \(xCodeVersion)", forType: .string)
                    }
                Spacer().frame(height: 20)
                HStack {
                    VStack(alignment: .leading, spacing: 15) {
                        WelcomeActionView(
                            iconName: "plus.square",
                            title: "Create a new file".localized(),
                            subtitle: "Create a new file".localized()
                        )
                            .onTapGesture {
                                CodeEditDocumentController.shared.newDocument(nil)
                                dismissWindow()
                            }
                        WelcomeActionView(
                            iconName: "folder",
                            title: "Open a file or folder".localized(),
                            subtitle: "Open an existing file or folder on your Mac".localized()
                        )
                            .onTapGesture {
                                CodeEditDocumentController.shared.openDocument { _, _ in
                                    dismissWindow()
                                }
                            }
                        WelcomeActionView(
                            iconName: "plus.square.on.square",
                            title: "Clone an exisiting project".localized(),
                            subtitle: "Start working on something from a Git repository".localized()
                        )
                            .onTapGesture {
                                // TODO: clone a Git repository
                            }
                    }
                }
                Spacer()
            }
            .frame(width: 384)
            .padding(.top, 20)
            .padding(.horizontal, 56)
            .padding(.bottom, 16)
            .background(Color(nsColor: colorScheme == .dark ? .windowBackgroundColor : .white))
            .onHover { isHovering in
                self.isHovering = isHovering
            }

            if isHovering {
                HStack(alignment: .center) {
                    dismissButton
                    Spacer()
                }.padding(13).transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.25)))
            }
            if isHovering {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Toggle("Show this window when CodeEdit launches", isOn: .init(get: {
                            return self.behavior == .welcome
                        }, set: { new in
                            self.behavior = new ? .welcome : .openPanel
                        }))
                            .toggleStyle(.checkbox)
                        Spacer()
                    }
                }
                .padding(.horizontal, 56)
                .padding(.bottom, 16)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.25)))
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(dismissWindow: {})
            .frame(width: 800, height: 460)
    }
}
