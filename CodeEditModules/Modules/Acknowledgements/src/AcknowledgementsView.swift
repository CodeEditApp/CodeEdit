//
//  AcknowledgementsView.swift
//
//
//  Created by Shivesh M M on 4/4/22.
//

import SwiftUI

public struct AcknowledgementsView: View {
    var acknowledgements: [Dependency]

    public init() {
        self.acknowledgements = []
        do {
            if let bundlePath = Bundle.main.path(forResource: "Package.resolved", ofType: nil) {
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8)
                let parsedJSON = try JSONDecoder().decode(RootObject.self, from: jsonData!)
                for dependency in parsedJSON.object.pins.sorted(by: {$0.package < $1.package}) {
                    // Filter out Dependencies containing CodeEdit (case insensitive)
                    if dependency.package.range(of: "[Cc]ode[Ee]dit",
                                                options: .regularExpression, range: nil, locale: nil) == nil {
                        self.acknowledgements.append(
                            Dependency(name: dependency.package,
                                       repositoryLink: dependency.repositoryURL,
                                       version: dependency.state.version ?? ""))
                    }
                }
            }
        } catch {
            print(error)
        }
    }

    init(_ dependencies: [Dependency]) {
        self.acknowledgements = dependencies
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Dependencies")
                .font(.system(size: 18, weight: .semibold)).padding([.leading, .top], 10.0)
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(acknowledgements, id: \.name) { acknowledgement in
                        AcknowledgementRow(acknowledgement: acknowledgement)
                            .listRowBackground(Color.clear)
                    }
                }.padding(.horizontal, 15)
            }
        }
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
                .padding(.leading, -5.0)
            Spacer()
            Button(action: {
                openURL(acknowledgement.repositoryURL)
            }, label: {
                Image(systemName: "arrow.right.circle.fill").foregroundColor(.secondary)
            }).buttonStyle(.plain)
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
        AcknowledgementsView([
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3")
        ])
        AcknowledgementsView([
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3")
        ]).preferredColorScheme(.light)
    }
}
