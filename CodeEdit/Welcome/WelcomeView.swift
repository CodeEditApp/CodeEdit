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

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 8) {
                Spacer().frame(height: 12)
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 128, height: 128)
                Text("Welcome to CodeEdit")
                    .font(.system(size: 38))
                Text("Version \(appVersion)(\(appBuild))")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))
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
                            iconName: "plus.square.on.square",
                            title: "Clone an exisiting project".localized(),
                            subtitle: "Start working on something from a Git repository".localized()
                        )
                            .onTapGesture {
                                // TODO: clone a Git repository
                            }
                        WelcomeActionView(
                            iconName: "folder",
                            title: "Open a project or file".localized(),
                            subtitle: "Open an existing project or file on your Mac".localized()
                        )
                            .onTapGesture {
                                CodeEditDocumentController.shared.openDocument { _, _ in
                                    dismissWindow()
                                }
                            }
                    }
                }
                Spacer()
            }
            .frame(width: 384)
            .padding(.top, 20)
            .padding(.horizontal, 56)
            .padding(.bottom, 16)
            .background(Color(nsColor: .windowBackgroundColor))
            .onHover { isHovering in
                self.isHovering = isHovering
            }

            if isHovering {
                HStack(alignment: .center) {
                    dismissButton
                    Spacer()
                }.padding(13).transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.25)))
            }
            if (isHovering) {
                VStack {
                    Spacer()
                    HStack() {
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
