//
//  UtilityAreaPortsView.swift
//  CodeEdit
//
//  Created by Leonardo Larrañaga on 4/21/25.
//

import SwiftUI

struct UtilityAreaPortsView: View {

    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    @State private var forwardedPorts = [UtilityAreaPort]()

    @State private var filterText = ""

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { _ in
            Group {
                if !forwardedPorts.isEmpty {
                    Text("Ports")
                } else {
                    CEContentUnavailableView(
                        "No Forwarded Ports",
                        description: "Add a port to access your services over the internet.",
                        systemImage: "powerplug"
                    ) {
                        Button("Forward a Port", action: forwardPort)
                    }
                }
            }
            .paneToolbar {
                Button("Add Port", systemImage: "plus", action: forwardPort)
                Button("Remove Port", systemImage: "minus", action: {})
                Spacer()
                UtilityAreaFilterTextField(title: "Filter", text: $filterText)
            }
        }
    }

    func forwardPort() {

    }
}
