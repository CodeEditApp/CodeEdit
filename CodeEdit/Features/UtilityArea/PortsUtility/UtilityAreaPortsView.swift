//
//  UtilityAreaPortsView.swift
//  CodeEdit
//
//  Created by Leonardo Larrañaga on 4/21/25.
//

import SwiftUI

struct UtilityAreaPortsView: View {

    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    @EnvironmentObject private var portsManager: PortsManager

    var ports: [UtilityAreaPort] {
        filterText.isEmpty ? portsManager.forwardedPorts : portsManager.forwardedPorts.filter { port in
            port.address.localizedCaseInsensitiveContains(filterText) ||
            port.label.localizedCaseInsensitiveContains(filterText)
        }
    }

    @State private var filterText = ""
    @State private var newPortAddress = ""
    var isValidPort: Bool {
        do {
            // swiftlint:disable:next line_length
            return try Regex(#"^(?:\d{1,5}|(?:[a-zA-Z0-9.-]+|\[[^\]]+\]):\d{1,5})$"#).wholeMatch(in: newPortAddress) != nil
        } catch {
            return false
        }
    }

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { _ in
            Group {
                if !portsManager.forwardedPorts.isEmpty {
                    Table(ports, selection: $portsManager.selectedPort) {
                        TableColumn("Port") { port in
                            if let index = portsManager.getIndex(for: port.id) {
                                    InlineEditRow(
                                        title: "Port Label",
                                        text: $portsManager.forwardedPorts[index].label,
                                        isEditing: $portsManager.forwardedPorts[index].isEditingLabel,
                                        onSubmit: {
                                            // Reselect the port after editing the label
                                            portsManager.selectedPort = port.id
                                        }
                                    )
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                        }
                        TableColumn("Forwarded Address", value: \.forwaredAddress)
                        TableColumn("Visibility", value: \.visibility.rawValue)
                        TableColumn("Origin", value: \.origin.rawValue)
                    }
                    .contextMenu(forSelectionType: UtilityAreaPort.ID.self) { items in
                        if let id = items.first,
                            let index = portsManager.forwardedPorts.firstIndex(where: { $0.id == id }) {
                            UtilityAreaPortsContextMenu(
                                port: $portsManager.forwardedPorts[index],
                                portsManager: portsManager
                            )
                        }
                    } primaryAction: { items in
                        if let index = portsManager.getIndex(for: items.first) {
                            portsManager.forwardedPorts[index].isEditingLabel = true
                            // Workaround: unselect the row to trigger the focus change
                            portsManager.selectedPort = nil
                        }
                    }
                } else {
                    CEContentUnavailableView(
                        "No Forwarded Ports",
                        description: "Add a port to access your services over the internet.",
                        systemImage: "powerplug"
                    ) {
                        Button("Forward a Port", action: portsManager.addForwardedPort)
                    }
                }
            }
            .paneToolbar {
                Button("Add Port", systemImage: "plus", action: portsManager.addForwardedPort)
                Button("Remove Port", systemImage: "minus") {
                    if let selectedPort = portsManager.getSelectedPort() {
                        portsManager.stopForwarding(port: selectedPort)
                    }
                }
                Spacer()
                UtilityAreaFilterTextField(title: "Filter", text: $filterText)
                    .frame(maxWidth: 175)
            }
            .alert("Foward a Port", isPresented: $portsManager.showAddPortAlert) {
                TextField("Port Number or Address", text: $newPortAddress)
                Button("Cancel", role: .cancel) {
                    newPortAddress = ""
                }
                Button("Forward") {
                    portsManager.forwardPort(with: newPortAddress)
                    newPortAddress = ""
                }
                .disabled(!isValidPort)
            }
        }
    }
}
