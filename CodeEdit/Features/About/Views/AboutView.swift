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

    public var body: some View {
        HStack(spacing: 0) {
            logo
            VStack(alignment: .leading, spacing: 0) {
                topMetaData
                Spacer()
                bottomMetaData
                actionButtons
            }
            .padding([.trailing, .vertical])
        }
        .background(.regularMaterial)
        .edgesIgnoringSafeArea(.top)
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
            Text("Version \(appVersion)\(appVersionPostfix) (\(appBuild))")
                .textSelection(.enabled)
                .foregroundColor(.secondary)
                .font(.system(size: 13, weight: .light))
        }
    }

    private var bottomMetaData: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let copyright = Bundle.copyrightString {
                Text(copyright)
            }
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
                Text("Acknowledgements")
                    .foregroundColor(.primary)
            }

            Button {
                openURL(URL(string: "https://github.com/CodeEditApp/CodeEdit/blob/main/LICENSE.md")!)
            } label: {
                Text("License Agreement")
                    .foregroundColor(.primary)
            }
        }
    }

    public func showWindow(width: CGFloat, height: CGFloat) {
        AboutViewWindowController(
            view: self,
            size: NSSize(width: width, height: height)
        )
        .showWindow(nil)
    }
}
