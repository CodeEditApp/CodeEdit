//
//  AboutDefaultView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 21/01/2023.
//

import SwiftUI

struct AboutDefaultView: View {
    private var appVersion: String {
        Bundle.versionString ?? "No Version"
    }

    private var appBuild: String {
        Bundle.buildString ?? "No Build"
    }

    private var appVersionPostfix: String {
        Bundle.versionPostfix ?? ""
    }

    @Binding var aboutMode: AboutMode
    var namespace: Namespace.ID
    @Environment(\.colorScheme) var colorScheme

    private static var licenseURL = URL(string: "https://github.com/CodeEditApp/CodeEdit/blob/main/LICENSE.md")!

    let smallTitlebarHeight: CGFloat = 28
    let mediumTitlebarHeight: CGFloat = 113
    let largeTitlebarHeight: CGFloat = 231

    var body: some View {
        VStack(spacing: 0) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .matchedGeometryEffect(id: "AppIcon", in: namespace)
                .frame(width: 128, height: 128)
                .padding(.top, 16)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                Text("CodeEdit")
                    .matchedGeometryEffect(id: "Title", in: namespace, properties: .position, anchor: .center)
                    .foregroundColor(.primary)
                    .font(.system(
                        size: 26,
                        weight: .bold
                    ))
                Text("Version \(appVersion)\(appVersionPostfix) (\(appBuild))")
                    .textSelection(.enabled)
                    .foregroundColor(Color(.tertiaryLabelColor))
                    .font(.body)
                    .blendMode(colorScheme == .dark ? .plusLighter : .plusDarker)
                    .padding(.top, 4)
                    .matchedGeometryEffect(
                        id: "Title",
                        in: namespace,
                        properties: .position,
                        anchor: UnitPoint(x: 0.5, y: -0.75)
                    )
            }
            .padding(.horizontal)
        }
        .padding(24)

        VStack {
            Spacer()
            VStack {
                Button {
                    aboutMode = .contributors
                } label: {
                    Text("Contributors")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .buttonStyle(.blur)

                Button {
                    aboutMode = .acknowledgements
                } label: {
                    Text("Acknowledgements")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .buttonStyle(.blur)

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
                .padding(.bottom, 24)
            }
            .matchedGeometryEffect(id: "Titlebar", in: namespace, properties: .position, anchor: .top)
            .matchedGeometryEffect(id: "ScrollView", in: namespace, properties: .position, anchor: .top)
        }
        .padding(.horizontal)
    }
}
