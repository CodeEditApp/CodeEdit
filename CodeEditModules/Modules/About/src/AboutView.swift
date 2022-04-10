import SwiftUI
import Acknowledgements

public struct AboutView: View {
    @Environment(\.openURL) var openURL

    @State var hoveringOnCommitHash = false

    public init() {}

    private var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    private var appBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }

    private var commitHash: String {
        return Bundle.main.object(forInfoDictionaryKey: "GitHash") as? String ?? ""
    }

    public var body: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: 32)
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 128, height: 128)
            Spacer().frame(width: 32)
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Spacer().frame(width: 6)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("CodeEdit").font(.system(size: 38, weight: .regular))
                        Text("Version \(appVersion) (\(appBuild))")
                            .textSelection(.enabled)
                            .foregroundColor(.secondary)
                            .font(.system(size: 13, weight: .light))
                        Spacer().frame(height: 5)
                        HStack(spacing: 2.0) {
                            Text("Commit:")
                            Text(self.hoveringOnCommitHash ?
                                    commitHash :
                                    String(commitHash[...commitHash.index(commitHash.startIndex, offsetBy: 7)]))
                                .textSelection(.enabled)
                                .onHover { _ in
                                    self.hoveringOnCommitHash.toggle()
                                }
                        }.foregroundColor(.secondary)
                            .font(.system(size: 10, weight: .light))
                        Spacer().frame(height: 36)
                        Text("Copyright © 2022 CodeEdit")
                            .foregroundColor(.secondary)
                            .font(.system(size: 9, weight: .light))
                            .lineSpacing(0.2)
                        Spacer().frame(height: 5)
                        Text("MIT License")
                            .foregroundColor(.secondary)
                            .font(.system(size: 9, weight: .light))
                            .lineSpacing(0.2)
                    }
                    Spacer().frame(width: 32)
                }
                Spacer()
                HStack(spacing: 0) {
                    Spacer().frame(width: 6)
                    Button(action: {
                        AcknowledgementsView().showWindow(width: 300, height: 400)
                    }, label: {
                        Text("Acknowledgments")
                            .frame(width: 136, height: 20)
                    })
                    Spacer().frame(width: 12)
                    Button(action: {
                        openURL(URL(string: "https://github.com/CodeEditApp/CodeEdit/blob/main/LICENSE.md")!)
                    }, label: {
                        Text("License Agreement")
                            .frame(width: 136, height: 20)
                    })
                    Spacer().frame(width: 16)
                }.frame(maxWidth: .infinity)
                Spacer().frame(height: 20)
            }
        }
    }

    public func showWindow(width: CGFloat, height: CGFloat) {
        PlaceholderWindowController(view: self, size: NSSize(width: width, height: height)).showWindow(nil)
    }
}

final class PlaceholderWindowController: NSWindowController {
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
            guard event.keyCode == 53 else { return event }

            self.closeAnimated()

            return nil
        }

        window?.collectionBehavior = [.transient, .ignoresCycle]
        window?.isMovableByWindowBackground = true
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden
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
