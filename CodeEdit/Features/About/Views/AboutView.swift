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
                .frame(width: 64, height: 64)
                .padding(10)

            Text("CodeEdit")
                .font(.title)
                .fontWeight(.bold)

            Text("Version \(appVersion)\(appVersionPostfix) (\(appBuild))")
                .textSelection(.enabled)
                .foregroundColor(.secondary)
                .font(.caption2)
                .padding(.vertical, 2)

            VStack {
                Button {

                } label: {
                    Text("Contributors")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }

                .controlSize(.large)

                Button {
                    AcknowledgementsView().showWindow(width: 300, height: 400)
                } label: {
                    Text("Acknowledgements")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
            }
            .padding(.vertical)

            Link(destination: Self.licenseURL) {
                Text("MIT License")
                    .underline()
                    .font(.caption3)
                    .textSelection(.disabled)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 2)

            Text(Bundle.copyrightString ?? "")
                .textSelection(.disabled)
                .foregroundColor(.secondary)
                .font(.caption3)
        }
        .padding([.horizontal, .bottom], 16)
        .frame(width: 280)
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
