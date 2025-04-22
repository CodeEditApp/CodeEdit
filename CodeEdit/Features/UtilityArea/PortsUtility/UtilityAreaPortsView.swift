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
    var ports: [UtilityAreaPort] {
        filterText.isEmpty ? forwardedPorts : forwardedPorts.filter { port in
            port.address.localizedCaseInsensitiveContains(filterText) ||
            port.label.localizedCaseInsensitiveContains(filterText)
        }
    }

    @State private var selectedPort: UtilityAreaPort.ID?

    @State private var filterText = ""

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { _ in
            Group {
                if !forwardedPorts.isEmpty {
                    Table(ports, selection: $selectedPort) {
                        TableColumn("Label", value: \.label)
                        TableColumn("Forwarded Address", value: \.forwaredAddress)
                        TableColumn("Visibility", value: \.visibility.rawValue)
                        TableColumn("Origin", value: \.origin.rawValue)
                    }
                    .contextMenu(forSelectionType: UtilityAreaPort.ID.self) { items in
                        if let id = items.first, let index = forwardedPorts.firstIndex(where: { $0.id == id }) {
                            UtilityAreaPortsContextMenu(port: $forwardedPorts[index])
                        }
                    }
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
                    .frame(maxWidth: 175)
            }
        }
    }

    func forwardPort() {
        forwardedPorts.append(UtilityAreaPort(address: "localhost", label: "Port \(forwardedPorts.count + 1)"))
    }
}
