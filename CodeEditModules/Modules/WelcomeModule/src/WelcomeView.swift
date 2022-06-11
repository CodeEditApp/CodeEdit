//
//  WelcomeView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import AppKit
import Foundation
import AppPreferences
import Git
import ShellClient

public struct WelcomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var showGitClone = false
    @State var showCheckoutBranch = false
    @State private var repoPath = "~/"
    @State var isHovering: Bool = false
    @State var isHoveringClose: Bool = false
    @StateObject private var prefs: AppPreferencesModel = .shared

    private let openDocument: (URL?, @escaping () -> Void) -> Void
    private let newDocument: () -> Void
    private let dismissWindow: () -> Void
    private let shellClient: ShellClient

    public init(
        shellClient: ShellClient,
        openDocument: @escaping (URL?, @escaping () -> Void) -> Void,
        newDocument: @escaping () -> Void,
        dismissWindow: @escaping () -> Void
    ) {
        self.shellClient = shellClient
        self.openDocument = openDocument
        self.newDocument = newDocument
        self.dismissWindow = dismissWindow
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    private var appBuild: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }

    /// Get the MacOS version & build
    private var macOsVersion: String {
        let url = URL(fileURLWithPath: "/System/Library/CoreServices/SystemVersion.plist")
        guard let dict = NSDictionary(contentsOf: url),
           let version = dict["ProductUserVisibleVersion"],
           let build = dict["ProductBuildVersion"]
        else {
            return ProcessInfo.processInfo.operatingSystemVersionString
        }

        return "\(version) (\(build))"
    }

    /// Return the Xcode version and build (if installed)
    private var xcodeVersion: String? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.dt.Xcode"),
              let bundle = Bundle(url: url),
              let infoDict = bundle.infoDictionary,
              let version = infoDict["CFBundleShortVersionString"] as? String,
              let buildURL = URL(string: "\(url)Contents/version.plist"),
              let buildDict = try? NSDictionary(contentsOf: buildURL, error: ()),
              let build = buildDict["ProductBuildVersion"]
        else {
            return nil
        }

        return "\(version) (\(build))"
    }

    /// Get the last commit hash.
    private var getGitHash: String? {
        if let hash = Bundle.main.infoDictionary?["GitHash"] as? String {
            return hash
        }

        return nil
    }

    /// Get program and operating system information
    private func copyInformation() {
        var copyString = "CodeEdit: \(appVersion) (\(appBuild))\n"

        if let hash = getGitHash {
            copyString.append("Commit: \(hash)\n")
        }

        copyString.append("MacOS: \(macOsVersion)\n")

        if let xcodeVersion = xcodeVersion {
            copyString.append("Xcode: \(xcodeVersion)")
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(copyString, forType: .string)
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 8) {
                Spacer().frame(height: 12)
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 128, height: 128)
                Text(NSLocalizedString("Welcome to CodeEdit", bundle: .module, comment: ""))
                    .font(.system(size: 38))
                Text(
                    String(
                        format: NSLocalizedString("Version %@ (%@)", bundle: .module, comment: ""),
                        appVersion,
                        appBuild
                    )
                )
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
                        copyInformation()
                    }

                Spacer().frame(height: 20)
                HStack {
                    VStack(alignment: .leading, spacing: 15) {
                        WelcomeActionView(
                            iconName: "plus.square",
                            title: NSLocalizedString("Create a new file", bundle: .module, comment: ""),
                            subtitle: NSLocalizedString("Create a new file", bundle: .module, comment: "")
                        )
                        .onTapGesture {
                            newDocument()
                            dismissWindow()
                        }
                        WelcomeActionView(
                            iconName: "folder",
                            title: NSLocalizedString("Open a file or folder", bundle: .module, comment: ""),
                            subtitle: NSLocalizedString(
                                "Open an existing file or folder on your Mac",
                                bundle: .module,
                                comment: ""
                            )
                        )
                        .onTapGesture {
                            openDocument(nil, dismissWindow)
                        }
                        WelcomeActionView(
                            iconName: "plus.square.on.square",
                            title: NSLocalizedString("Clone an exisiting project", bundle: .module, comment: ""),
                            subtitle: NSLocalizedString(
                                "Start working on something from a Git repository",
                                bundle: .module,
                                comment: ""
                            )
                        )
                            .onTapGesture {
                                showGitClone = true
                            }
                    }
                }
                Spacer()
            }
            .frame(width: 384)
            .padding(.top, 20)
            .padding(.horizontal, 56)
            .padding(.bottom, 16)
            .background(Color(colorScheme == .dark ? NSColor.windowBackgroundColor : .white))
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
                            prefs.preferences.general.reopenBehavior == .welcome
                        }, set: { new in
                            prefs.preferences.general.reopenBehavior = new ? .welcome : .openPanel
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
        .sheet(isPresented: $showGitClone) {
            GitCloneView(
                shellClient: shellClient,
                isPresented: $showGitClone,
                showCheckout: $showCheckoutBranch,
                repoPath: $repoPath
            )
        }
        .sheet(isPresented: $showCheckoutBranch) {
            CheckoutBranchView(
                isPresented: $showCheckoutBranch,
                repoPath: $repoPath,
                shellClient: shellClient
            )
        }
    }

    private var dismissButton: some View {
        Button(
            action: dismissWindow,
            label: {
                Circle()
                    .fill(isHoveringClose ? .secondary : Color(.clear))
                    .frame(width: 13, height: 13)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 8.5, weight: .heavy, design: .rounded))
                            .foregroundColor(isHoveringClose ? Color(NSColor.windowBackgroundColor) : .secondary)
                    )
            }
        )
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(Text("Close"))
        .onHover { hover in
            isHoveringClose = hover
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(
            shellClient: .live(),
            openDocument: { _, _  in },
            newDocument: {},
            dismissWindow: {}
        )
        .frame(width: 800, height: 460)
    }
}
