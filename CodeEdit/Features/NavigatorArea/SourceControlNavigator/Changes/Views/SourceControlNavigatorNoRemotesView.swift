//
//  SourceControlNavigatorNoRemotesView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/17/23.
//

import SwiftUI

struct SourceControlNavigatorNoRemotesView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager

    @State private var addRemoteIsPresented: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label(
                    title: {
                        Text("No remotes")
                    }, icon: {
                        Image(systemName: "network")
                            .foregroundColor(.secondary)
                    }
                )
                Spacer()
                Button("Add") {
                    addRemoteIsPresented = true
                }
                .sheet(isPresented: $addRemoteIsPresented) {
                    SourceControlAddRemoteView()
                }
            }
        }
    }
}
