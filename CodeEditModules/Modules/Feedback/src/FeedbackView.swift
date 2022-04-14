//
//  FeedbackView.swift
//  
//
//  Created by Nanashi Li on 2022/04/14.
//

import SwiftUI

public struct FeedbackView: View {

    public init() {}

    @State var feedbackTitle: String = ""
    @State var issueAreaListSelection: Int = 0
    @State var issueAreaList = ["Please select the problem area",
                                "Project Navigator",
                                "Extensions",
                                "Git",
                                "Debugger",
                                "Editor"]
    @State var feedbackTypeListSelection: Int = 0
    @State var feedbackTypeList = ["Choose...",
                                   "Incorrect/Unexpected Behaviour",
                                   "Application Crash",
                                   "Application Slow/Unresponsive",
                                   "Suggestion"]

    public var body: some View {
        VStack {
            ScrollView(content: {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .fontWeight(.bold)
                        .font(.system(size: 20))

                    VStack(alignment: .leading) {
                        Text("Please provide a descriptive title for your feedback:")
                        TextField("", text: $feedbackTitle)
                        Text("Example: CodeEdit crashes when using autocomplete")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }.padding(.top, -5)

                    VStack(alignment: .leading) {
                        Text("Which area are you seeing an issue with?")
                        Picker("", selection: $issueAreaListSelection) {
                            ForEach(0..<issueAreaList.count) {
                                if issueAreaListSelection == 0 {
                                    Text(self.issueAreaList[$0])
                                        .foregroundColor(.secondary)
                                } else {
                                    Text(self.issueAreaList[$0])
                                }
                            }
                        }.labelsHidden()
                    }.padding(.top)

                    VStack(alignment: .leading) {
                        Text("What type of feedback are you reporting?")
                        Picker("", selection: $feedbackTypeListSelection) {
                            ForEach(0..<feedbackTypeList.count) {
                                if feedbackTypeListSelection == 0 {
                                    Text(self.feedbackTypeList[$0])
                                        .foregroundColor(.secondary)
                                } else {
                                    Text(self.feedbackTypeList[$0])
                                }
                            }
                        }.labelsHidden()
                    }.padding(.top)

                    Text("Description")
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                        .padding(.top)

                    VStack(alignment: .leading) {
                        Text("Please describe the issue:")
                        TextEditor(text: $feedbackTitle)
                                   .frame(minHeight: 127, alignment: .leading)
                        Text("Example: CodeEdit crashes when the autocomplete popup appears on screen.")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }.padding(.top, -5)

                    VStack(alignment: .leading) {
                        Text("Please list the steps you took to reproduce the issue:")
                        TextEditor(text: $feedbackTitle)
                                   .frame(minHeight: 60, alignment: .leading)
                        Text("Example:")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text("1. Open the attached sample project")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text("2. type #import and wait for autocompletion to begin")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }.padding(.top)

                    VStack(alignment: .leading) {
                        Text("What did you expect to happen?")
                        TextEditor(text: $feedbackTitle)
                                   .frame(minHeight: 60, alignment: .leading)
                        Text("Example: I expected autocomplete to show me a list of headers.")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }.padding(.top)

                    // swiftlint:disable line_length
                    VStack(alignment: .leading) {
                        Text("What actually happened?")
                        TextEditor(text: $feedbackTitle)
                                   .frame(minHeight: 60, alignment: .leading)
                        Text("Example: The autocomplete window flickered on screen and CodeEdit crashed. See attached crashlog.")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }.padding(.top)
                }.padding(EdgeInsets(top: 30, leading: 90, bottom: 30, trailing: 90))
            }).border(Color(NSColor.separatorColor))
            FeedbackToolbar {
                Button {} label: {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 20.0, height: 20.0)
                }.buttonStyle(.plain)
                Spacer()
                Button {} label: {
                    Text("Submit")
                }
            }
            .padding(10)
        }
        .frame(width: 1028, height: 762)
    }

    public func showWindow() {
        FeedbackWindowController(view: self, size: NSSize(width: 1028, height: 762)).showWindow(nil)
    }
}

final class FeedbackWindowController: NSWindowController {
    convenience init<T: View>(view: T, size: NSSize) {
        let hostingController = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: hostingController)
        self.init(window: window)
        window.title = "Feedback for CodeEdit"
        window.setContentSize(size)
        window.styleMask.remove(.resizable)
    }

    override func showWindow(_ sender: Any?) {
        window?.center()
        window?.alphaValue = 0.0

        super.showWindow(sender)

        window?.animator().alphaValue = 1.0

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

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
