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

    private var appVersionPostfix: String {
        Bundle.versionPostfix ?? ""
    }

    private static var licenseURL = URL(string: "https://github.com/CodeEditApp/CodeEdit/blob/main/LICENSE.md")!

    public var body: some View {
        VStack(spacing: 0) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 70, height: 70)

            Text("CodeEdit")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Version \(appVersion)\(appVersionPostfix) (\(appBuild))")
                .textSelection(.enabled)
                .foregroundColor(.secondary)
                .font(.caption)
                .padding(.vertical, 2)

            VStack {
                Button {

                } label: {
                    Text("Contributors")
                        .foregroundColor(.primary)
                }

                Button {
                    AcknowledgementsView().showWindow(width: 300, height: 400)
                } label: {
                    Text("Acknowledgements")
                        .foregroundColor(.primary)
                }
            }
            .padding(.vertical)

            Link(destination: Self.licenseURL) {
                Text("MIT License")
                    .underline()
                    .font(.caption)
                    .textSelection(.disabled)
                    .foregroundColor(.secondary)

            }

            Text(Bundle.copyrightString ?? "")
                .textSelection(.disabled)
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.horizontal, 50)
        .padding(.bottom, 20)
        .padding(.top, 10)
        .fixedSize()
        .background(.regularMaterial)
    }

    public func showWindow(width: CGFloat, height: CGFloat) {
        AboutViewWindowController(
            view: self,
            size: NSSize(width: width, height: height)
        )
        .showWindow(nil)
    }
}
