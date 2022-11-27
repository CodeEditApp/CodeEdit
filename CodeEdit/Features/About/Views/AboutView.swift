//
//  AboutView.swift
//  CodeEditModules/About
//
//  Created by Andrei Vidrasco on 02.04.2022
//

import SwiftUI

public struct AboutView: View {
    @Environment(\.openURL) private var openURL

    public init() {}

    private var appVersion: String {
        Bundle.versionString ?? "No Version"
    }

    private var appBuild: String {
        Bundle.buildString ?? "No Build"
    }

    public var body: some View {
        HStack(spacing: 0) {
            logo
            VStack(alignment: .leading, spacing: 0) {
                topMetaData
                Spacer()
                bottomMetaData
                actionButtons
            }
            .padding([.trailing, .bottom])
        }
    }

    // MARK: Sub-Views

    private var logo: some View {
        Image(nsImage: NSApp.applicationIconImage)
            .resizable()
            .frame(width: 128, height: 128)
            .padding(32)
    }

    private var topMetaData: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("CodeEdit").font(.system(size: 38, weight: .regular))
            Text("Version \(appVersion) (\(appBuild))")
                .textSelection(.enabled)
                .foregroundColor(.secondary)
                .font(.system(size: 13, weight: .light))
        }
    }

    private var bottomMetaData: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Copyright © 2022 CodeEdit")
            Text("MIT License")
        }
        .foregroundColor(.secondary)
        .font(.system(size: 9, weight: .light))
        .padding(.bottom, 10)
    }

    private var actionButtons: some View {
        HStack {
            Button {
                AcknowledgementsView().showWindow(width: 300, height: 400)
            } label: {
                Text("Acknowledgments")
                    .frame(maxWidth: .infinity)
            }
            Button {
                guard let url = URL(string: "https://github.com/CodeEditApp/CodeEdit/blob/main/LICENSE.md")
                else { return }
                openURL(url)
            } label: {
                Text("License Agreement")
                    .frame(maxWidth: .infinity)
            }
        }
    }

    public func showWindow(width: CGFloat, height: CGFloat) {
        AboutViewWindowController(view: self,
                                    size: NSSize(width: width,
                                                 height: height))
        .showWindow(nil)
    }
}

final class AboutViewWindowController: NSWindowController {
    convenience init<T: View>(view: T, size: NSSize) {
        let hostingController = NSHostingController(rootView: view)
        // New window holding our SwiftUI view
        let window = NSWindow(contentViewController: hostingController)
        self.init(window: window)
        window.setContentSize(size)
        window.styleMask.remove(.resizable)
        window.styleMask.insert(.fullSizeContentView)
        window.alphaValue = 0.5
        window.styleMask.remove(.miniaturizable)
    }

    override func showWindow(_ sender: Any?) {
        window?.center()
        window?.alphaValue = 0.0

        super.showWindow(sender)

        window?.animator().alphaValue = 1.0

        // close the window when the escape key is pressed
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            print("Abt View")
            guard event.keyCode == 53 else { return event }

            self.closeAnimated()

            return nil
        }

        window?.collectionBehavior = [.transient, .ignoresCycle]
        window?.isMovableByWindowBackground = true
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden
        window?.isExcludedFromWindowsMenu = true
    }

    func closeAnimated() {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0.4
        NSAnimationContext.current.completionHandler = {
            self.close()
        }
        window?.animator().alphaValue = 0.0
        NSAnimationContext.endGrouping()
    }
}

struct About_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .frame(width: 530, height: 220)
    }
}
