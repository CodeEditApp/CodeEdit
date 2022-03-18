//
//  WelcomeView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import AppKit
import Foundation

struct WelcomeView: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 8) {
                Spacer()
                Image("appicon")
                    .resizable()
                    .frame(width: 128, height: 128)
                Text("Welcome to CodeEdit")
                    .bold()
                    .font(.system(size: 28))
                Text("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)(\(NSApplication.version()))")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                Spacer().frame(height: 20)
                HStack {
                    VStack(alignment: .leading) {
                        HStack(spacing: 15) {
                            Image(systemName: "plus.square")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            VStack(alignment: .leading) {
                                Text("Create a new file")
                                    .bold()
                                    .font(.system(size: 16))
                                Text("Create a new file")
                                    .font(.system(size: 14))
                            }
                        }
                        HStack(spacing: 15) {
                            Image(systemName: "plus.square.on.square")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            VStack(alignment: .leading) {
                                Text("Clone an exisiting project")
                                    .bold()
                                    .font(.system(size: 16))
                                Text("Start working on something from a Git repository")
                                    .font(.system(size: 14))
                            }
                        }
                        HStack(spacing: 15) {
                            Image(systemName: "folder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            VStack(alignment: .leading) {
                                Text("Open a project or file")
                                    .bold()
                                    .font(.system(size: 16))
                                Text("Open an existing project or file on your Mac")
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
            .frame(width: 480)
            .padding(.vertical, 24)
            .padding(.horizontal, 32)
            .background(Color(red: 48 / 255, green: 48 / 255, blue: 48 / 255))
            RecentProjectsView()
            
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .frame(width: 780, height: 600)
    }
}
