//
//  AcknowledgementsView.swift
//  
//
//  Created by Shivesh M M on 4/4/22.
//

import SwiftUI

public struct AcknowledgementsView: View {
    var acknowledgements: [Dependency] = []

    public init() {
        do {
            if let bundlePath = Bundle.main.path(forResource: "Package.resolved", ofType: nil) {
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8)
                let parsedJSON = try JSONDecoder().decode(RootObject.self, from: jsonData!)
                for dependency in parsedJSON.object.pins {
                    self.acknowledgements.append(
                        Dependency(name: dependency.package,
                                   repositoryLink: dependency.repositoryURL,
                                   version: dependency.state.version))
                }
            }
        } catch {
            print("Unable to open Package.resolved")
        }
    }

    public var body: some View {
        List(acknowledgements, id: \.name) { acknowledgement in
            AcknowledgementRow(acknowledgement: acknowledgement)
        }.padding(.vertical, 10.0)
    }

    public func showWindow(width: CGFloat, height: CGFloat) {
        PlaceholderWindowController(view: self, size: NSSize(width: width, height: height)).showWindow(nil)
    }
}

struct AcknowledgementRow: View {
    @Environment(\.openURL) var openURL

    var acknowledgement: Dependency

    var body: some View {
        HStack(alignment: .bottom) {
            Text(acknowledgement.name)
                .bold()
            Text(acknowledgement.version)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Button(action: {openURL(acknowledgement.repositoryURL)}, label: {
                Text("Link")
                Image(systemName: "arrow.up.right")
            })
        }
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
//        window?.titlebarAppearsTransparent = true
        window?.title = "Acknowledgements"
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

struct Acknowledgements_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgementsView()
    }
}
