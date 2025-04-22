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
}
