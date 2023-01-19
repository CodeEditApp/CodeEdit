//
//  AboutView.swift
//  CodeEditModules/About
//
//  Created by Andrei Vidrasco on 02.04.2022
//

import SwiftUI

public struct AboutView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme

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
        VStack(spacing: 32) {
            VStack(spacing: 0) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 128, height: 128)
                    .padding(.bottom, 8)

                VStack(spacing: 4) {
                    Text("CodeEdit")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Version \(appVersion)\(appVersionPostfix) (\(appBuild))")
                        .textSelection(.enabled)
                        .foregroundColor(Color(.tertiaryLabelColor))
                        .font(.body)
                        .blendMode(colorScheme == .dark ? .plusLighter : .plusDarker)
                }
            }

            VStack {
                Button {
                    ContributorsView().showWindow(width: 300, height: 400)
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

                VStack(spacing: 2) {
                    Link(destination: Self.licenseURL) {
                        Text("MIT License")
                            .underline()

                    }
                    Text(Bundle.copyrightString ?? "")
                }
                .textSelection(.disabled)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color(.tertiaryLabelColor))
                .blendMode(colorScheme == .dark ? .plusLighter : .plusDarker)
                .padding(.top, 12)
                .padding(.bottom, 8)
            }
        }
        .padding(16)
        .frame(width: 280)
        .fixedSize()
        // hack required to get buttons appearing correctly in light appearance
        // if anyone knows of a better way to do this feel free to refactor
        .background(.regularMaterial.opacity(0))
        .background(EffectView(.popover, blendingMode: .behindWindow).ignoresSafeArea())
    }

    public func showWindow(width: CGFloat, height: CGFloat) {
        AboutViewWindowController(
            view: self,
            size: NSSize(width: width, height: height)
        )
        .showWindow(nil)
    }
}
