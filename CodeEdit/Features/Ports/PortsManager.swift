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

    func getIndex(for id: UtilityAreaPort.ID?) -> Int? {
        forwardedPorts.firstIndex { $0.id == id }
    }

    func getSelectedPort() -> UtilityAreaPort? {
        forwardedPorts.first { $0.id == selectedPort }
    }

    func addForwardedPort() {
        showAddPortAlert = true
    }

    func forwardPort(with address: String) {
        let newPort = UtilityAreaPort(address: address)
        newPort.forwaredAddress = address
        forwardedPorts.append(newPort)
        selectedPort = newPort.id
        newPort.isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            DispatchQueue.main.async {
                newPort.isLoading = false
                newPort.notifyConnection()
            }
        }
    }

    func stopForwarding(port: UtilityAreaPort) {
        forwardedPorts.removeAll { $0.id == port.id }
    }
}
