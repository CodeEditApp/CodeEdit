//
//  PortsManager.swift
//  CodeEdit
//
//  Created by Leonardo Larrañaga on 4/21/25.
//

import SwiftUI

/// This class manages the forwarded ports for the utility area.
class PortsManager: ObservableObject {
    @Published var forwardedPorts = [UtilityAreaPort]()
    @Published var selectedPort: UtilityAreaPort.ID?

    @Published var showAddPortAlert = false

    func getSelectedPort() -> UtilityAreaPort? {
        forwardedPorts.first { $0.id == selectedPort }
    }

    func addForwardedPort() {
        showAddPortAlert = true
    }

    func forwardPort(with address: String) {
        let newPort = UtilityAreaPort(address: address)
        forwardedPorts.append(newPort)
        selectedPort = newPort.id
    }

    func stopForwarding(port: UtilityAreaPort) {
        forwardedPorts.removeAll { $0.id == port.id }
    }
}
