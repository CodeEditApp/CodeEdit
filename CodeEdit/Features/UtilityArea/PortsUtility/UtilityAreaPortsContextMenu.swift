//
//  UtilityAreaPortsMenu.swift
//  CodeEdit
//
//  Created by Leonardo Larrañaga on 4/21/25.
//

import SwiftUI

struct UtilityAreaPortsContextMenu: View {

    @Binding var port: UtilityAreaPort
    @ObservedObject var portsManager: PortsManager

    var body: some View {
        Group {
            Link("Open in Browser", destination: URL(string: port.forwaredAddress) ??
                 URL(string: "https://localhost:3000")!)
            Button("Preview in Editor", action: {})
            Divider()

            Button("Set Port Label", action: {})
            Divider()

            Button("Copy Local Address", action: {})
                .keyboardShortcut("c", modifiers: [.command])
            Picker("Port Visiblity", selection: $port.visibility) {
                ForEach(UtilityAreaPort.Visibility.allCases, id: \.self) { visibility in
                    Text(visibility.rawValue)
                        .tag(visibility)
                }
            }
            Picker("Change Port Protocol", selection: $port.portProtocol) {
                ForEach(UtilityAreaPort.PortProtocol.allCases, id: \.self) { protocolType in
                    Text(protocolType.rawValue)
                        .tag(protocolType)
                }
            }
            Divider()

            Button("Stop Forwarding Port") {
                portsManager.stopForwarding(port: port)
            }
            .keyboardShortcut(.delete, modifiers: [.command])
            Button("Forward a Port", action: portsManager.addForwardedPort)
        }
    }
}
